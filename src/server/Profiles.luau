--!strict
-- Live servers use a leased record. Studio stays in memory and never touches live data.
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Rules=require(script.Parent.GameRules)
local Profiles={}
local leases={}
local records={}
local store=nil
local saving={}
local function clean(data)
	local p=Rules.profile()
	if typeof(data)=="table" then
		for key,value in pairs(p) do
			if typeof(value)=="number" and typeof(data[key])=="number" and data[key]==data[key] then p[key]=math.clamp(math.floor(data[key]),0,1000000000) end
		end
		p.ownsLens=data.ownsLens==true
	end
	return p
end
local function retry(callback)
	local last=nil
	for attempt=1,3 do
		local ok,result=pcall(callback)
		if ok then return true,result end
		last=result if attempt<3 then task.wait(attempt) end
	end
	return false,last
end
function Profiles.load(player)
	if Run:IsStudio() then local p=Rules.profile() records[player]=p return p,"SESSION" end
	if not store then store=game:GetService("DataStoreService"):GetDataStore("TRIL_HorrorProfiles_v1") end
	local id=Http:GenerateGUID(false)
	local ok,result=retry(function()
		return store:UpdateAsync("Player_"..player.UserId,function(old)
			if typeof(old)=="table" and typeof(old.lease)=="table" and (old.lease.expires or 0)>os.time() and old.lease.id~=id then return nil end
			return {data=clean(if typeof(old)=="table" then old.data else nil),lease={id=id,expires=os.time()+180}}
		end)
	end)
	local p=clean(if ok and result then result.data else nil)
	records[player]=p
	if ok and result and result.lease.id==id then leases[player]=id return p,"SAVED" end
	warn("[TRIL] Profile unavailable for "..player.UserId.."; using session-only progress")
	return p,"SESSION"
end
function Profiles.save(player,release,waitForPrevious)
	if saving[player] then
		if not release and not waitForPrevious then return false end
		local deadline=os.clock()+15
		while saving[player] and os.clock()<deadline do task.wait(0.1) end
		if saving[player] then return false end
	end
	local p=records[player] local id=leases[player]
	if not p or not id or not store then return false end
	saving[player]=true
	-- Copy before yielding; purchases during an autosave are retained for the next save.
	local data=clean(p)
	local ok,result=retry(function()
		return store:UpdateAsync("Player_"..player.UserId,function(old)
			if typeof(old)~="table" or not old.lease or old.lease.id~=id then return nil end
			return {data=data,lease=if release then nil else {id=id,expires=os.time()+180}}
		end)
	end)
	saving[player]=nil
	return ok and result~=nil
end
function Profiles.remove(player)
	Profiles.save(player,true) records[player]=nil leases[player]=nil
end
function Profiles.shutdown()
	local pending=0
	for player in pairs(records) do pending+=1 task.spawn(function() Profiles.save(player,true) pending-=1 end) end
	local deadline=os.clock()+24
	while pending>0 and os.clock()<deadline do task.wait(0.1) end
end
return Profiles
