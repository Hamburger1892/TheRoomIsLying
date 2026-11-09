--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local World=require(script.Parent.WorldBuilder)
local Rules=require(script.Parent.GameRules)
local Profiles=require(script.Parent.Profiles)
local Settings=require(RS.TRILShared.Settings)
local random=Random.new()
local preview=workspace:FindFirstChild("TRILHorrorPreview") if preview then preview:Destroy() end
local oldPreview=workspace:FindFirstChild("TRILRoomPreview") if oldPreview then oldPreview:Destroy() end
World.lighting()
assert(not workspace:FindFirstChild("TRILLobby"),"Install one horror bootstrap")
local lobby=World.lobby(workspace)
local maps=Instance.new("Folder") maps.Name="TRILMatches" maps.Parent=workspace
local net=Instance.new("Folder") net.Name="TRILHorrorNet" net.Parent=RS
local action=Instance.new("RemoteEvent") action.Name="Action" action.Parent=net
local feed=Instance.new("RemoteEvent") feed.Name="Feed" feed.Parent=net
local entries={} local matches={} local slots={} local queue={}
local queueEnd=0 local nextId=0 local startMatch
local function now() return workspace:GetServerTimeNow() end
local function count(t) local n=0 for _ in pairs(t) do n+=1 end return n end
local function toast(player,text,good) feed:FireClient(player,"Toast",{text=text,good=good}) end

local function publish(player)
	local e=entries[player] if not e then return end
	local p=e.data or Rules.profile() local m=e.match local r=m and m.players[player]
	local s={location=e.location,ready=e.ready,coins=p.coins,score=p.score,streak=p.streak,bestStreak=p.bestStreak,ownsLens=p.ownsLens,saveMode=e.saveMode,hint=e.hint}
	if m and r then
		s.map=m.key s.mapName=Settings.Maps[m.key].name s.phase=m.phase s.round=m.round s.total=Settings.RoundsPerVisit
		s.endsAt=m.endsAt s.duration=m.duration s.finds=r.finds s.voted=r.vote~=nil s.choice=r.vote s.lensUsed=r.lensUsed s.party=count(m.players)
		s.result=r.result s.reveal=if m.phase=="Results" then m.reveal else nil
		s.mapId=m.id
	elseif e.location=="Queue" then s.endsAt=queueEnd s.queueCount=#queue end
	player:SetAttribute("TRILHorror",Http:JSONEncode(s))
	local stats=player:FindFirstChild("leaderstats")
	if stats then stats.MindCoins.Value=p.coins stats.Score.Value=p.score stats.Streak.Value=p.streak end
end
local function publishMatch(m) for player in pairs(m.players) do publish(player) end end
local function move(player)
	local e=entries[player] local character=player.Character
	if not e or not character then return end
	local root=character:FindFirstChild("HumanoidRootPart") local humanoid=character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end
	local m=e.match
	local destination=if m and m.map then m.map.spawn else lobby.spawn
	character:PivotTo(destination)
	root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
	root.Anchored=m~=nil and m.phase=="Blackout"
	humanoid.WalkSpeed=14 humanoid.JumpPower=40
	humanoid.CameraOffset=if m and m.map then Vector3.new(1.5,0.4,0) else Vector3.zero
	player.CameraMode=Enum.CameraMode.Classic
	player.CameraMinZoomDistance=if m then 7 else 4 player.CameraMaxZoomDistance=if m then 7 else 18
	task.delay(0.3,function() if entries[player]==e and e.match==m then player.CameraMinZoomDistance=3.5 player.CameraMaxZoomDistance=if m then 10 else 18 end end)
end
local function near(player,anchor,container,distance)
	local char=player.Character local root=char and char:FindFirstChild("HumanoidRootPart") local hum=char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health<=0 then return false end
	local delta=anchor.Position-root.Position
	if delta.Magnitude>distance then return false end
	local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={char}
	local hit=workspace:Raycast(root.Position,delta,params)
	return hit==nil or hit.Instance:IsDescendantOf(container)
end
local function cleanup(m)
	m.active=false
	if m.building then return end
	for _,connection in m.connections do connection:Disconnect() end
	if m.folder then m.folder:Destroy() end
	if slots[m.slot]==m.id then slots[m.slot]=nil end
	matches[m.id]=nil
end
local function removeQueue(player)
	local index=table.find(queue,player) if index then table.remove(queue,index) end
	if #queue==0 then queueEnd=0 end
	for _,other in queue do publish(other) end
end
local function returnLobby(player,message)
	local e=entries[player] if not e then return end
	removeQueue(player)
	local m=e.match
	if m then m.players[player]=nil if count(m.players)==0 then cleanup(m) else publishMatch(m) end end
	e.match=nil e.location="Lobby" e.hint=nil
	move(player) publish(player)
	if message then toast(player,message,true) end
end

local function lens(player)
	local e=entries[player] local m=e and e.match local r=m and m.players[player]
	if not e or not e.ready or not e.data.ownsLens then toast(player,"The Curator sells the Truth Lens for 1,000 Mind Coins.",false) return end
	if not m or m.phase~="Search" or now()>=m.endsAt or not r then toast(player,"Use the lens while searching a room.",false) return end
	if r.lensUsed then toast(player,"The lens has already spoken this round.",false) return end
	local tool=player:FindFirstChildOfClass("Backpack") and player.Backpack:FindFirstChild("Truth Lens")
	local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if tool and humanoid then humanoid:EquipTool(tool) end
	task.delay(1.2,function() if entries[player]==e and player.Character and player.Character:FindFirstChild("Truth Lens") then local h=player.Character:FindFirstChildOfClass("Humanoid") if h then h:UnequipTools() end end end)
	r.lensUsed=true
	local n=count(m.missing)
	e.hint=if n==0 then "TRUTH LENS: NOTHING IS MISSING." else string.format("TRUTH LENS: %d OBJECTS ARE MISSING.",n)
	toast(player,e.hint,true) publish(player)
end
local function grantTool(player)
	local e=entries[player] if not e or not e.data or not e.data.ownsLens then return end
	local bag=player:FindFirstChildOfClass("Backpack") if not bag then return end
	if bag:FindFirstChild("Truth Lens") or (player.Character and player.Character:FindFirstChild("Truth Lens")) then return end
	local tool=Instance.new("Tool") tool.Name="Truth Lens" tool.ToolTip="Reveal one answer per search round" tool.CanBeDropped=false
	local handle=Instance.new("Part") handle.Name="Handle" handle.Size=Vector3.new(0.28,2,0.28)*0.55 handle.Color=Color3.fromRGB(84,53,33) handle.Material=Enum.Material.Wood handle.CanCollide=false handle.Massless=true handle.Parent=tool
	local function attach(name,size,cf,color,material)
		local p=Instance.new("Part") p.Name=name p.Size=size*0.55 p.CFrame=handle.CFrame*CFrame.new(cf.Position*0.55)*cf.Rotation p.Color=color p.Material=material p.CanCollide=false p.Massless=true p.Parent=tool
		local weld=Instance.new("WeldConstraint") weld.Part0=handle weld.Part1=p weld.Parent=p return p
	end
	for i=1,12 do local a=i*math.pi/6 attach("BrassRim",Vector3.new(0.32,0.5,0.18),CFrame.new(math.sin(a)*0.8,1.7+math.cos(a)*0.8,0)*CFrame.Angles(0,0,-a),Color3.fromRGB(187,146,72),Enum.Material.Metal) end
	local glass=attach("Lens",Vector3.new(1.4,1.4,0.09),CFrame.new(0,1.7,0),Color3.fromRGB(129,211,219),Enum.Material.Glass) glass.Shape=Enum.PartType.Ball glass.Transparency=0.55
	tool.Activated:Connect(function() if tool.Parent==player.Character then lens(player) end end)
	tool.Parent=bag
end

local function waitPhase(m)
	while m.active and count(m.players)>0 and now()<m.endsAt do task.wait(0.1) end
	return m.active and count(m.players)>0
end
local function phase(m,name,seconds)
	m.phase=name m.duration=seconds m.endsAt=now()+seconds publishMatch(m)
end
local function freeze(m,enabled)
	for player in pairs(m.players) do local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if root then root.Anchored=enabled end end
end
local function duration(name,fallback)
	local value=if Run:IsStudio() then script:GetAttribute(name) else nil
	return if typeof(value)=="number" then math.clamp(value,1,180) else fallback
end
startMatch=function(key,players)
	assert(Settings.Maps[key] and #players<=Settings.Maps[key].capacity,"Invalid party size")
	local slot=nil for i=1,16 do if not slots[i] then slot=i break end end
	if not slot then for _,p in players do returnLobby(p,"All investigation rooms are occupied. Try again shortly.") end return end
	nextId+=1 local id="Visit_"..nextId
	local m={id=id,key=key,players={},slot=slot,round=0,phase="Loading",duration=0,endsAt=0,missing={},active=true,building=true,connections={}}
	slots[slot]=id matches[id]=m
	m.folder=Instance.new("Folder") m.folder.Name=id m.folder.Parent=maps
	for _,player in players do
		local e=entries[player]
		if e and e.ready then removeQueue(player) e.location="Match" e.match=m e.hint=nil m.players[player]=Rules.record() publish(player) end
	end
	task.spawn(function()
		local ok,problem=pcall(function()
			m.map=World.map(key,Vector3.new(800+slot*180,48,0),m.folder)
			m.building=false
			if not m.active or count(m.players)==0 then cleanup(m) return end
			for index,target in m.map.targets do
				table.insert(m.connections,target.prompt.Triggered:Connect(function(player)
					local e=entries[player] local r=m.players[player]
					if not e or e.match~=m or not r or not m.active then return end
					if e.lastInspect and now()-e.lastInspect<0.4 then return end
					e.lastInspect=now()
					if not target.prompt.Enabled or not near(player,target.anchor,target.model,9) then return end
					local found,message=Rules.find(r,index,m,now())
					if found then
						e.data.coins+=Settings.FindCoins e.data.foundTotal+=1 e.data.xp+=10
						feed:FireClient(player,"Evidence",{mapId=m.id,index=index})
						toast(player,target.label.." was missing! +"..Settings.FindCoins.." Mind Coins",true) publish(player)
					else toast(player,message,false) end
				end))
			end
			local config=Settings.Maps[key]
			for round=1,Settings.RoundsPerVisit do
				if not m.active or count(m.players)==0 then break end
				World.reset(m.map) m.round=round m.missing={} m.reveal=nil
				for player in pairs(m.players) do m.players[player]=Rules.record() entries[player].hint=nil move(player) end
				phase(m,"Memorize",duration("MemorizeSeconds",config.memorize))
				if not waitPhase(m) then break end
				freeze(m,true) phase(m,"Blackout",duration("BlackoutSeconds",Settings.BlackoutSeconds))
				task.wait(0.5)
				local changed=random:NextNumber()<Settings.ChangeChance
				if Run:IsStudio() and script:GetAttribute("ForceChanged")~=nil then changed=script:GetAttribute("ForceChanged")==true end
				if changed then
					local order={} for i=1,#m.map.targets do table.insert(order,i) end
					for i=#order,2,-1 do local j=random:NextInteger(1,i) order[i],order[j]=order[j],order[i] end
					local amount=random:NextInteger(config.minMissing,config.maxMissing)
					for i=1,amount do m.missing[order[i]]=true end
				end
				World.hide(m.map,m.missing)
				if not waitPhase(m) then break end
				freeze(m,false)
				for _,target in m.map.targets do target.prompt.Enabled=true end
				phase(m,"Search",duration("SearchSeconds",config.search))
				if not waitPhase(m) then break end
				for _,target in m.map.targets do target.prompt.Enabled=false end
				m.phase="Results" local labels={} local indices={}
				for index in pairs(m.missing) do table.insert(labels,m.map.targets[index].label) table.insert(indices,index) end
				m.reveal={changed=changed,count=#labels,labels=labels,indices=indices}
				for player,r in pairs(m.players) do r.result=Rules.reward(entries[player].data,r,changed,Settings) end
				phase(m,"Results",duration("ResultsSeconds",Settings.ResultsSeconds))
				if not waitPhase(m) then break end
			end
			if m.active then
				local returning={} for player in pairs(m.players) do table.insert(returning,player) end
				for _,player in returning do entries[player].data.coins+=Settings.CompletionCoins returnLobby(player,"Investigation complete. +"..Settings.CompletionCoins.." Mind Coins.") end
			end
		end)
		m.building=false
		if not ok then
			warn("[TRIL] Investigation error: "..tostring(problem))
			local returning={} for player in pairs(m.players) do table.insert(returning,player) end
			for _,player in returning do returnLobby(player,"That room is unavailable. You have been returned safely.") end
		end
		cleanup(m)
	end)
end

local function addPlayer(player)
	if entries[player] then return end
	local e={location="Lobby",ready=false,saveMode="LOADING"} entries[player]=e
	local stats=Instance.new("Folder") stats.Name="leaderstats" stats.Parent=player
	for _,name in ipairs({"MindCoins","Score","Streak"}) do local n=Instance.new("IntValue") n.Name=name n.Parent=stats end
	e.characterConnection=player.CharacterAdded:Connect(function(character)
		local root=character:WaitForChild("HumanoidRootPart",10)
		if root and entries[player]==e then move(player) if e.ready then grantTool(player) end end
	end)
	if player.Character then task.spawn(function() player.Character:WaitForChild("HumanoidRootPart",10) move(player) end) end
	publish(player)
	local data,mode=Profiles.load(player)
	if entries[player]~=e then Profiles.remove(player) return end
	e.data=data e.saveMode=mode e.ready=true grantTool(player) publish(player)
end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(function(player)
	local e=entries[player] if not e then return end
	removeQueue(player)
	if e.match then local m=e.match m.players[player]=nil if count(m.players)==0 then cleanup(m) else publishMatch(m) end end
	if e.characterConnection then e.characterConnection:Disconnect() end
	entries[player]=nil Profiles.remove(player)
end)
for _,player in Players:GetPlayers() do task.spawn(addPlayer,player) end

local function npcAction(npc,kind)
	npc.prompt.Triggered:Connect(function(player)
		local e=entries[player]
		if not e or e.location~="Lobby" or not near(player,npc.anchor,npc.model,12) then return end
		feed:FireClient(player,kind,{})
	end)
end
npcAction(lobby.shop,"Shop") npcAction(lobby.keeper,"Play") npcAction(lobby.guide,"Guide")

action.OnServerEvent:Connect(function(player,verb,arg,extra)
	local e=entries[player] if not e or not e.ready or typeof(verb)~="string" then return end
	local t=now() if e.lastAction and t-e.lastAction<0.2 then return end e.lastAction=t
	if verb=="Play" then
		if e.buying then toast(player,"Your purchase is being saved. Please wait.",false) return end
		if e.location~="Lobby" or (arg~="Solo" and arg~="Trio") then return end
		if arg=="Solo" then startMatch("Solo",{player}) else
			e.location="Queue" table.insert(queue,player) if #queue==1 then queueEnd=t+Settings.QueueSeconds end
			for _,p in queue do publish(p) end
		end
	elseif verb=="Leave" then returnLobby(player)
	elseif verb=="BuyLens" then
		if e.location~="Lobby" or not near(player,lobby.shop.anchor,lobby.shop.model,13) then toast(player,"Speak to the Curator at the shop first.",false) return end
		if not Run:IsStudio() and e.saveMode~="SAVED" then toast(player,"Your saved record is unavailable. Rejoin before buying a permanent item.",false) return end
		local bought,message=Rules.buy(e.data,Settings.LensPrice)
		if bought then
			grantTool(player)
			if not Run:IsStudio() then
				e.buying=true local saved=Profiles.save(player,false,true) e.buying=false
				if not saved then e.saveMode="UNSAVED" message="Lens acquired; saving is pending. Stay connected while the game retries." end
			end
		end
		toast(player,message,bought) publish(player)
	elseif verb=="Lens" then lens(player)
	elseif verb=="Vote" then
		local m=e.match local r=m and m.players[player]
		if m and r and Rules.vote(r,arg,extra,m,t) then publish(player) toast(player,"Answer locked. Keep searching for bonus evidence.",true) end
	end
end)

task.spawn(function()
	while true do
		task.wait(0.25)
		if #queue>0 and (#queue>=3 or now()>=queueEnd) then
			local group={} while #queue>0 and #group<3 do local p=table.remove(queue,1) local e=entries[p] if e and e.location=="Queue" then table.insert(group,p) end end
			queueEnd=if #queue>0 then now()+Settings.QueueSeconds else 0
			if #group>0 then startMatch("Trio",group) end
			for _,p in queue do publish(p) end
		end
	end
end)
task.spawn(function()
	while true do
		task.wait(60)
		for player,e in pairs(entries) do
			if e.ready and e.saveMode~="SESSION" then task.spawn(function() e.saveMode=if Profiles.save(player,false) then "SAVED" else "UNSAVED" publish(player) end) end
		end
	end
end)
game:BindToClose(Profiles.shutdown)
-- Only a local Studio command can access these QA helpers; no client remote exists.
if Run:IsStudio() then
	local qa=Instance.new("BindableFunction") qa.Name="TRILHorrorQA" qa.Parent=game.ServerStorage
	qa.OnInvoke=function(command,player,amount)
		local e=entries[player]
		if command=="GrantCoins" and e and e.ready and typeof(amount)=="number" then e.data.coins=math.clamp(math.floor(amount),0,100000) publish(player) return true end
		if command=="State" and e then
			local m=e.match local indices={} if m then for i in pairs(m.missing) do table.insert(indices,i) end table.sort(indices) end
			return {location=e.location,coins=e.data.coins,ownsLens=e.data.ownsLens,matchId=m and m.id,party=m and count(m.players),phase=m and m.phase,missingIndices=indices}
		end
		return nil
	end
end
print("[TRIL] Horror lobby ready. Solo study / 1-3 player manor / Truth Lens shop.")
