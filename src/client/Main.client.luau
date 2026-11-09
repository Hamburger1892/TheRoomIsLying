--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Input=game:GetService("UserInputService")
local player=Players.LocalPlayer
local UI=require(script.Parent.ObservationUI)
local audio=require(RS:WaitForChild("TRILShared"):WaitForChild("Audio"))
local net=RS:WaitForChild("TRILNet")
local vote=net:WaitForChild("Vote")
local stateFolder=RS:WaitForChild("TRILState")
local camera=workspace.CurrentCamera
local originalType=camera.CameraType
local originalFov=camera.FieldOfView
local connections={}
local revealObjects={}
local lastPhase=nil
local lastSecond=-1
local lastViewport=Vector2.zero
local lastRound=-1
local state=nil
local ui=UI.new(player:WaitForChild("PlayerGui"),function(roundId,choice) vote:FireServer(roundId,choice) end)
local controls=nil
local hiddenTouch={}
local function hideTouch(gui)
	if gui.Name~="TouchGui" or not gui:IsA("ScreenGui") or hiddenTouch[gui]~=nil then return end
	hiddenTouch[gui]=gui.Enabled
	gui.Enabled=false
	table.insert(connections,gui:GetPropertyChangedSignal("Enabled"):Connect(function() if gui.Enabled then gui.Enabled=false end end))
end
for _,gui in player.PlayerGui:GetChildren() do hideTouch(gui) end
table.insert(connections,player.PlayerGui.ChildAdded:Connect(hideTouch))
task.spawn(function()
	local module=player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule",10)
	if module then
		local ok,playerModule=pcall(require,module)
		if ok then controls=playerModule:GetControls() controls:Disable() end
	end
end)

local sounds={}
for name,id in pairs(audio) do
	if typeof(id)=="string" and string.match(id,"^rbxassetid://[1-9]%d*$") then
		local sound=Instance.new("Sound") sound.Name="TRIL_"..name sound.SoundId=id sound.Volume=0.35
		sound.Looped=name=="Ambience" sound.Parent=game:GetService("SoundService") sounds[name]=sound
		if sound.Looped then sound:Play() end
	end
end
local function play(name) local sound=sounds[name] if sound then sound:Play() end end
local function clearReveal()
	for _,object in revealObjects do object:Destroy() end table.clear(revealObjects)
end
local function showReveal(reveal)
	clearReveal()
	local room=workspace:FindFirstChild("TRILObservationRoom") if not room then return end
	for _,name in ipairs(reveal.objects or {}) do
		local object=room:FindFirstChild(name)
		if object and object:IsA("Model") then
			local cf,size=object:GetBoundingBox()
			local anchor=Instance.new("Part") anchor.Name="TRILReveal" anchor.Anchored=true anchor.Transparency=1 anchor.CanCollide=false anchor.CanTouch=false anchor.CanQuery=false anchor.Size=size+Vector3.new(0.25,0.25,0.25) anchor.CFrame=cf anchor.Parent=workspace
			local outline=Instance.new("SelectionBox") outline.Adornee=anchor outline.Color3=Color3.fromRGB(105,240,202) outline.LineThickness=0.06 outline.SurfaceTransparency=0.92 outline.SurfaceColor3=outline.Color3 outline.Parent=anchor
			table.insert(revealObjects,anchor)
		end
	end
end
local function decode(raw)
	if typeof(raw)~="string" then return nil end
	local ok,value=pcall(function() return Http:JSONDecode(raw) end)
	return if ok and typeof(value)=="table" then value else nil
end
local function personal()
	local profile=decode(player:GetAttribute("TRILProfile"))
	if profile then ui:personal(profile) end
end
local function snapshot()
	local s=decode(stateFolder:GetAttribute("Snapshot")) if not s then return end
	state=s ui:roundState(s) personal()
	if s.phase~=lastPhase or s.round~=lastRound then
		clearReveal()
		if s.phase=="Blackout" then play("Blackout") end
		if s.phase=="Results" and s.reveal then
			showReveal(s.reveal)
			local p=ui.profile
			if p and p.result then play(if p.result.correct then "Correct" else "Incorrect") if p.result.correct and p.streak%5==0 then play("Streak") end end
		end
		lastPhase=s.phase lastRound=s.round
	end
end
table.insert(connections,stateFolder:GetAttributeChangedSignal("Snapshot"):Connect(snapshot))
table.insert(connections,player:GetAttributeChangedSignal("TRILProfile"):Connect(personal))
table.insert(connections,Input.InputBegan:Connect(function(key,processed)
	if processed then return end
	if key.KeyCode==Enum.KeyCode.One or key.KeyCode==Enum.KeyCode.ButtonX then ui:submit(true) end
	if key.KeyCode==Enum.KeyCode.Two or key.KeyCode==Enum.KeyCode.ButtonY then ui:submit(false) end
end))
table.insert(connections,Run.RenderStepped:Connect(function()
	camera=workspace.CurrentCamera if not camera then return end
	camera.CameraType=Enum.CameraType.Scriptable
	local view=camera.ViewportSize
	local aspect=math.max(0.25,view.X/math.max(view.Y,1))
	-- Fit the entire 36-stud scene even in portrait, without allowing free-look.
	local scale=math.max(1,1.45/aspect)
	local side=view.Y<550 and aspect>1.3
	local sidebar=if view.X<700 then 212 else 232
	if side then scale=math.max(1,1.45/math.max(0.5,(view.X-sidebar-36)/view.Y)) end
	local target=Vector3.new(0,53.5,0)
	camera.FieldOfView=42
	camera.CFrame=CFrame.lookAt(target+Vector3.new(8,21,42)*scale,target)
	if side then
		local span=2*(Vector3.new(8,21,42)*scale).Magnitude*math.tan(math.rad(21))*aspect
		camera.CFrame*=CFrame.new(span*(sidebar-8)/(2*view.X),0,0)
	end
	if view~=lastViewport then ui:layout(view) lastViewport=view end
	local now=workspace:GetServerTimeNow() ui:tick(now)
	if state and state.phase=="Memorize" then
		local second=math.ceil(state.endsAt-now)
		if second~=lastSecond and second<=5 and second>0 then play("Tick") end lastSecond=second
	end
end))
snapshot() personal()
script.Destroying:Connect(function()
	for _,connection in connections do connection:Disconnect() end
	clearReveal() ui:destroy()
	for _,sound in pairs(sounds) do sound:Destroy() end
	if controls then controls:Enable() end
	for gui,enabled in pairs(hiddenTouch) do if gui.Parent then gui.Enabled=enabled end end
	if camera then camera.CameraType=originalType camera.FieldOfView=originalFov end
end)
