--!strict
-- Builds detached geometry so a caller can parent or discard the whole room.
local RoomBuilder = {}
local BLUE = Color3.fromRGB(65, 155, 255)
local AMBER = Color3.fromRGB(255, 185, 65)
local INK = Color3.fromRGB(43, 35, 70)

export type Room = {
	model: Model,
	spawn: CFrame,
	clues: { ProximityPrompt },
	doors: { [string]: ProximityPrompt },
	replay: ProximityPrompt,
}

local function part(model: Model, name: string, size: Vector3, position: Vector3, color: Color3): Part
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Color = color
	object.Anchored = true
	object.Material = Enum.Material.SmoothPlastic
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = model
	return object
end

local function label(target: BasePart, text: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(210, 52)
	gui.StudsOffset = Vector3.new(0, target.Size.Y / 2 + 1, 0)
	gui.MaxDistance = 52
	gui.AlwaysOnTop = false
	gui.Parent = target
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundColor3 = INK
	textLabel.BackgroundTransparency = 0.12
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Font = Enum.Font.Cartoon
	textLabel.TextSize = 20
	textLabel.TextWrapped = true
	textLabel.Text = text
	textLabel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = textLabel
end

local function prompt(target: BasePart, objectText: string, action: string): ProximityPrompt
	local item = Instance.new("ProximityPrompt")
	item.Name = "Interact"
	item.ObjectText = objectText
	item.ActionText = action
	item.HoldDuration = 0
	item.MaxActivationDistance = 9
	item.RequiresLineOfSight = true
	item.KeyboardKeyCode = Enum.KeyCode.E
	item.GamepadKeyCode = Enum.KeyCode.ButtonX
	item.ClickablePrompt = true
	item.Parent = target
	return item
end

function RoomBuilder.build(origin: Vector3, ownerId: number): Room
	local model = Instance.new("Model")
	model.Name = "Room_" .. ownerId
	model:SetAttribute("OwnerUserId", ownerId)
	part(model, "Floor", Vector3.new(36, 1, 32), origin, Color3.fromRGB(255, 225, 152))
	part(model, "BackWall", Vector3.new(36, 16, 1), origin + Vector3.new(0, 8, -16), Color3.fromRGB(207, 180, 255))
	part(model, "FrontWall", Vector3.new(36, 16, 1), origin + Vector3.new(0, 8, 16), Color3.fromRGB(207, 180, 255))
	for _, x in ipairs({ -18, 18 }) do
		part(model, "SideWall", Vector3.new(1, 16, 32), origin + Vector3.new(x, 8, 0), Color3.fromRGB(176, 235, 219))
	end
	-- A transparent physical ceiling prevents jumping into adjacent rooms.
	local roof = part(model, "Ceiling", Vector3.new(36, 1, 32), origin + Vector3.new(0, 16, 0), INK)
	roof.Transparency = 1
	local rug = part(model, "Rug", Vector3.new(18, 0.15, 12), origin + Vector3.new(0, 0.6, 2), Color3.fromRGB(255, 139, 178))
	rug.CanCollide = false

	local clock = part(model, "Clock", Vector3.new(3, 4, 2), origin + Vector3.new(-12, 2.5, 1), AMBER)
	local face = part(model, "ClockFace", Vector3.new(2.4, 2.4, 0.2), origin + Vector3.new(-12, 3, 2.15), Color3.fromRGB(255, 250, 226))
	face.CanCollide = false
	face.CanQuery = false
	label(face, "TICK TOCK")
	local plant = part(model, "PlantPot", Vector3.new(3, 2, 3), origin + Vector3.new(12, 1.5, 1), Color3.fromRGB(247, 135, 96))
	local leaves = part(model, "Leaves", Vector3.new(4, 4, 4), origin + Vector3.new(12, 4, 1), Color3.fromRGB(83, 205, 137))
	leaves.Shape = Enum.PartType.Ball
	leaves.CanCollide = false
	leaves.CanQuery = false
	label(leaves, "FERNANDO")
	local portrait = part(model, "Portrait", Vector3.new(4, 4, 1), origin + Vector3.new(0, 4, 13), Color3.fromRGB(255, 151, 206))
	label(portrait, "SMUG PORTRAIT")
	local blueDoor = part(model, "BlueDoor", Vector3.new(7, 9, 1), origin + Vector3.new(-8, 5, -14.8), BLUE)
	local amberDoor = part(model, "AmberDoor", Vector3.new(7, 9, 1), origin + Vector3.new(8, 5, -14.8), AMBER)
	label(blueDoor, "BLUE EXIT")
	label(amberDoor, "AMBER EXIT")
	local replay = part(model, "ReplayButton", Vector3.new(3, 1, 3), origin + Vector3.new(0, 1, -10), INK)
	label(replay, "PLAY AGAIN")
	local replayPrompt = prompt(replay, "Encore button", "Play again")
	replayPrompt.Enabled = false
	return {
		model = model,
		spawn = CFrame.new(origin + Vector3.new(0, 4, 6)),
		clues = { prompt(clock, "Tick Tock", "Inspect"), prompt(plant, "Fernando", "Inspect"), prompt(portrait, "Smug Portrait", "Inspect") },
		doors = { BLUE = prompt(blueDoor, "BLUE exit", "Choose exit"), AMBER = prompt(amberDoor, "AMBER exit", "Choose exit") },
		replay = replayPrompt,
	}
end

return RoomBuilder
