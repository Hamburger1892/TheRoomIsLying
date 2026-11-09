--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Builder=require(script.Parent.RoomBuilder)
local Anomalies=require(script.Parent.Anomalies)
local Rules=require(script.Parent.RoundRules)
local Tuning=require(script.Parent.Tuning)
local random=Random.new()

local preview=workspace:FindFirstChild("TRILRoomPreview") if preview then preview:Destroy() end
assert(not workspace:FindFirstChild("TRILObservationRoom"),"Only one TRIL server bootstrap can run")
local room=Builder.build() room.model.Parent=workspace
local baseline=Anomalies.capture(room)
local stage=Instance.new("Part") stage.Name="TRILBackstage" stage.Size=Vector3.new(40,1,16)
stage.Anchored=true stage.Transparency=1 stage.Position=room.origin+Vector3.new(0,-15,45) stage.Parent=workspace

local net=RS:FindFirstChild("TRILNet") or Instance.new("Folder") net.Name="TRILNet" net.Parent=RS
local voteEvent=net:FindFirstChild("Vote") or Instance.new("RemoteEvent") voteEvent.Name="Vote" voteEvent.Parent=net
local stateFolder=RS:FindFirstChild("TRILState") or Instance.new("Folder") stateFolder.Name="TRILState" stateFolder.Parent=RS
local profiles={}
local round=0
local phase="Waiting"
local endsAt=0
local duration=0
local difficulty=1
local reveal=nil
local currentTuning=Tuning.get()
local resultsResolved=false
local lastRequests={}

local function personal(player)
	local p=profiles[player] if not p then return end
	player:SetAttribute("TRILProfile",Http:JSONEncode({
		score=p.score,coins=p.coins,xp=p.xp,level=math.floor(p.xp/100)+1,streak=p.streak,
		bestStreak=p.bestStreak,totalCorrect=p.totalCorrect,lifetimeCoins=p.lifetimeCoins,
		eligible=p.eligibleRound==round,voted=p.vote~=nil,result=p.result,
	}))
	local stats=player:FindFirstChild("leaderstats")
	if stats then stats.Score.Value=p.score stats.Streak.Value=p.streak stats.MindCoins.Value=p.coins end
end
local function broadcast()
	local leaders={}
	local voted,eligible=0,0
	for player,p in pairs(profiles) do
		table.insert(leaders,{name=player.DisplayName,id=player.UserId,score=p.score,streak=p.streak})
		if p.eligibleRound==round then eligible+=1 if p.vote~=nil then voted+=1 end end
	end
	table.sort(leaders,function(a,b) if a.score==b.score then return a.id<b.id end return a.score>b.score end)
	while #leaders>8 do table.remove(leaders) end
	-- Anomaly details are deliberately absent until Results.
	stateFolder:SetAttribute("Snapshot",Http:JSONEncode({
		round=round,phase=phase,endsAt=endsAt,duration=duration,difficulty=difficulty,
		voted=voted,eligible=eligible,leaders=leaders,reveal=if phase=="Results" then reveal else nil,
	}))
end
local function setPhase(name,seconds)
	phase=name duration=seconds endsAt=workspace:GetServerTimeNow()+seconds
	broadcast()
end
local function waitForPhase()
	while workspace:GetServerTimeNow()<endsAt do task.wait(0.1) end
end
local function characterAdded(player,character)
	local root=character:WaitForChild("HumanoidRootPart",10)
	if not root or not profiles[player] or player.Character~=character then return end
	character:PivotTo(CFrame.new(stage.Position+Vector3.new(0,4,0)))
	root.Anchored=true -- Avatars stay backstage and never obstruct the shared scene.
end
local function addPlayer(player)
	if profiles[player] then return end
	local p=Rules.profile() profiles[player]=p
	local stats=Instance.new("Folder") stats.Name="leaderstats" stats.Parent=player
	for _,name in ipairs({"Score","Streak","MindCoins"}) do local value=Instance.new("IntValue") value.Name=name value.Parent=stats end
	p.characterConnection=player.CharacterAdded:Connect(function(character) characterAdded(player,character) end)
	if player.Character then task.spawn(characterAdded,player,player.Character) end
	-- Joining after a round starts means spectating until the next memorization.
	personal(player) broadcast()
end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(function(player)
	local p=profiles[player] if p and p.characterConnection then p.characterConnection:Disconnect() end
	profiles[player]=nil lastRequests[player]=nil broadcast()
end)
for _,player in Players:GetPlayers() do addPlayer(player) end

voteEvent.OnServerEvent:Connect(function(player,roundId,choice)
	local p=profiles[player] if not p then return end
	local now=workspace:GetServerTimeNow()
	if lastRequests[player] and now-lastRequests[player]<0.2 then return end
	lastRequests[player]=now
	local accepted=Rules.vote(p,roundId,choice,phase,round,now,endsAt)
	if accepted then personal(player) broadcast() end
end)

task.spawn(function()
	while true do
		if next(profiles)==nil then
			Anomalies.restore(baseline) reveal=nil setPhase("Waiting",0)
			-- Wait for profile initialization, not just the Player entering the tree.
			repeat task.wait(0.25) until next(profiles)~=nil
		end
		currentTuning=Tuning.get()
		Anomalies.restore(baseline) reveal=nil resultsResolved=false
		round+=1 difficulty=if round<=3 then 1 else if round<=7 then 2 else 3
		for player,p in pairs(profiles) do p.eligibleRound=round p.vote=nil p.result=nil personal(player) end
		setPhase("Memorize",currentTuning.MemorizeSeconds) waitForPhase()
		setPhase("Blackout",currentTuning.BlackoutSeconds)
		-- Let every client cover the room before replicated geometry changes.
		task.wait(0.6)
		local kind="None"
		if random:NextNumber()<currentTuning.ChangeChance then kind=Anomalies.kinds[random:NextInteger(1,#Anomalies.kinds)] end
		if RunService:IsStudio() then
			local forced=script.Parent.Anomalies:GetAttribute("ForceKind")
			if forced=="None" or table.find(Anomalies.kinds,forced) then kind=forced end
		end
		local answer=Anomalies.apply(room,kind,difficulty)
		waitForPhase()
		setPhase("Vote",currentTuning.VoteSeconds) waitForPhase()
		-- Close phase before touching rewards so a boundary vote cannot race scoring.
		phase="Results"
		assert(not resultsResolved,"Round already scored") resultsResolved=true
		local correct=0
		for player,p in pairs(profiles) do
			if p.eligibleRound==round then p.result=Rules.reward(p,answer.changed,currentTuning) if p.result.correct then correct+=1 end end
			personal(player)
		end
		local names={} for _,model in answer.targets do table.insert(names,model.Name) end
		reveal={changed=answer.changed,description=answer.description,objects=names,correct=correct,kind=answer.kind}
		setPhase("Results",currentTuning.ResultsSeconds) waitForPhase()
	end
end)
print("[TRIL] Observation game ready: " .. #room.items .. " environmental objects, synchronized rounds")
