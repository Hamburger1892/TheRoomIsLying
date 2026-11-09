--!strict
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TRILHud"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.DisplayOrder = 10

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 8)
panel.Size = UDim2.new(0.92, 0, 0, 0)
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.BackgroundColor3 = Color3.fromRGB(43, 35, 70)
panel.BackgroundTransparency = 0.05
panel.Parent = gui
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(600, 1000)
limit.Parent = panel
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = panel
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 14)
padding.PaddingRight = UDim.new(0, 14)
padding.Parent = panel
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = panel

local function line(name: string, order: number, size: number, color: Color3): TextLabel
	local item = Instance.new("TextLabel")
	item.Name = name
	item.LayoutOrder = order
	item.Size = UDim2.new(1, 0, 0, 0)
	item.AutomaticSize = Enum.AutomaticSize.Y
	item.BackgroundTransparency = 1
	item.Font = Enum.Font.Cartoon
	item.TextSize = size
	item.TextColor3 = color
	item.TextWrapped = true
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.RichText = false
	item.Text = ""
	item.Parent = panel
	return item
end

local title = line("Title", 1, 22, Color3.fromRGB(255, 221, 115))
title.Text = "THE ROOM IS LYING"
local progress = line("Progress", 2, 16, Color3.fromRGB(147, 229, 255))
progress.Text = "Waiting for your room..."
local notes = line("Notebook", 3, 16, Color3.fromRGB(255, 249, 226))
local feedback = line("Feedback", 4, 17, Color3.fromRGB(255, 209, 226))
local notebookButton = Instance.new("TextButton")
notebookButton.Name = "ToggleNotebook"
notebookButton.LayoutOrder = 5
notebookButton.Size = UDim2.new(1, 0, 0, 32)
notebookButton.BackgroundColor3 = Color3.fromRGB(83, 68, 122)
notebookButton.TextColor3 = Color3.new(1, 1, 1)
notebookButton.TextSize = 16
notebookButton.Font = Enum.Font.Cartoon
notebookButton.Parent = panel
local camera = workspace.CurrentCamera
notes.Visible = not camera or camera.ViewportSize.Y >= 500
local function updateNotebookButton()
	notebookButton.Text = if notes.Visible then "Hide notebook" else "Show notebook"
end
notebookButton.Activated:Connect(function()
	notes.Visible = not notes.Visible
	updateNotebookButton()
end)
updateNotebookButton()

local function render()
	local raw = player:GetAttribute("TRILSnapshot")
	if typeof(raw) ~= "string" then return end
	local ok, state = pcall(function() return HttpService:JSONDecode(raw) end)
	if not ok or typeof(state) ~= "table" or typeof(state.notes) ~= "table" then return end
	progress.Text = string.format("ROOM %d / %d   |   CLUES %d / 3", state.round, state.total, state.seen)
	notes.Text = table.concat(state.notes, "\n")
	feedback.Text = state.message
	if state.phase == "Won" then
		progress.Text = "ALL THREE ROOMS SOLVED!"
	end
end

player:GetAttributeChangedSignal("TRILSnapshot"):Connect(render)
gui.Parent = player:WaitForChild("PlayerGui")
render() -- Handles joining after the first server snapshot was already sent.
