--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Input=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local player=Players.LocalPlayer
local settings=require(RS:WaitForChild("TRILShared"):WaitForChild("Settings"))
local net=RS:WaitForChild("TRILHorrorNet") local action=net:WaitForChild("Action")
local Interface=require(script.Parent.Interface)
local state=nil local connections={} local outlines={} local lastRound=""
local flashlightOn=true local sprinting=false
local lamp=Instance.new("Part") lamp.Name="TRILLocalFlashlight" lamp.Size=Vector3.new(0.1,0.1,0.1) lamp.Anchored=true lamp.Transparency=1 lamp.CanCollide=false lamp.CanQuery=false lamp.CanTouch=false lamp.Parent=workspace
local spot=Instance.new("SpotLight") spot.Name="Flashlight" spot.Face=Enum.NormalId.Front spot.Color=Color3.fromRGB(223,224,208) spot.Brightness=2.8 spot.Range=36 spot.Angle=72 spot.Shadows=true spot.Parent=lamp
local function toggleLight() flashlightOn=not flashlightOn spot.Enabled=flashlightOn end
local function send(verb,arg,extra) action:FireServer(verb,arg,extra) end
local ui=Interface.new(player:WaitForChild("PlayerGui"),settings,send,toggleLight)
local function clear() for _,o in outlines do o:Destroy() end table.clear(outlines) end
local function mark(mapId,index,color)
	local folder=workspace:FindFirstChild("TRILMatches") local visit=folder and folder:FindFirstChild(mapId) if not visit then return end
	local map=visit:FindFirstChildWhichIsA("Model") local display=map and map:FindFirstChild("Display_"..index) local base=display and display:FindFirstChild("DisplayBase") if not base then return end
	local h=Instance.new("Highlight") h.Name="YourEvidence" h.Adornee=base h.FillColor=color h.OutlineColor=color h.FillTransparency=0.55 h.DepthMode=Enum.HighlightDepthMode.Occluded h.Parent=base table.insert(outlines,h)
end
local function update()
	local raw=player:GetAttribute("TRILHorror") if typeof(raw)~="string" then return end
	local ok,s=pcall(function() return Http:JSONDecode(raw) end) if not ok or typeof(s)~="table" then return end
	local key=tostring(s.mapId)..":"..tostring(s.round)
	if key~=lastRound or s.location~="Match" then clear() lastRound=key end
	if s.phase=="Results" and state and state.phase~="Results" and s.reveal then for _,index in ipairs(s.reveal.indices) do mark(s.mapId,index,Color3.fromRGB(223,185,104)) end end
	state=s ui:update(s)
	player.CameraMode=Enum.CameraMode.Classic
end
table.insert(connections,player:GetAttributeChangedSignal("TRILHorror"):Connect(update))
table.insert(connections,net.Feed.OnClientEvent:Connect(function(kind,data)
	if kind=="Shop" or kind=="Guide" or kind=="Play" then ui:open(kind)
	elseif kind=="Toast" then ui:toast(data.text,data.good)
	elseif kind=="Evidence" then mark(data.mapId,data.index,Color3.fromRGB(130,218,193)) end
end))
table.insert(connections,Input.InputBegan:Connect(function(key,processed)
	if processed then return end
	if key.KeyCode==Enum.KeyCode.F then toggleLight()
	elseif key.KeyCode==Enum.KeyCode.Q then send("Lens")
	elseif key.KeyCode==Enum.KeyCode.One then ui:vote(true)
	elseif key.KeyCode==Enum.KeyCode.Two then ui:vote(false)
	elseif key.KeyCode==Enum.KeyCode.LeftShift then sprinting=true
	elseif key.KeyCode==Enum.KeyCode.P and state and state.location=="Lobby" then ui:open("Play") end
end))
table.insert(connections,Input.InputEnded:Connect(function(key) if key.KeyCode==Enum.KeyCode.LeftShift then sprinting=false end end))
local oldBackpack=true
pcall(function() oldBackpack=game.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) end)
local lastViewport=Vector2.zero
table.insert(connections,Run.RenderStepped:Connect(function()
	local camera=workspace.CurrentCamera if not camera then return end
	if camera.CameraType==Enum.CameraType.Scriptable then camera.CameraType=Enum.CameraType.Custom end
	local head=player.Character and player.Character:FindFirstChild("Head")
	local origin=if head then head.Position+camera.CFrame.LookVector*0.8 else camera.CFrame.Position
	lamp.CFrame=CFrame.lookAt(origin,origin+camera.CFrame.LookVector)
	spot.Enabled=flashlightOn and not (state and state.phase=="Blackout")
	local char=player.Character local humanoid=char and char:FindFirstChildOfClass("Humanoid")
	if humanoid and not (state and state.phase=="Blackout") then humanoid.WalkSpeed=if sprinting then 20 else 14 end
	if camera.ViewportSize~=lastViewport then lastViewport=camera.ViewportSize ui:layout(lastViewport) end
	ui:tick(workspace:GetServerTimeNow())
end))
update()
script.Destroying:Connect(function()
	for _,c in connections do c:Disconnect() end clear() ui:destroy() lamp:Destroy()
	player.CameraMode=Enum.CameraMode.Classic player.CameraMaxZoomDistance=18
	pcall(function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,oldBackpack) end)
end)
