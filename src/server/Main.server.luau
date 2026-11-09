--!strict
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Puzzle = require(script.Parent.Puzzle)
local RoomBuilder = require(script.Parent.RoomBuilder)

local ROUND_COUNT = 3
local CAPACITY = 12 -- Set the experience's Max Players to 12 or fewer.
local SNAPSHOT_ATTRIBUTE = "TRILSnapshot"
local random = Random.new()
local clueNames = { "Tick Tock", "Fernando", "Smug Portrait" }
assert(not workspace:FindFirstChild("TRILRooms"), "TRILRooms already exists; install only one Main script")
local rooms = Instance.new("Folder")
rooms.Name = "TRILRooms"
rooms.Parent = workspace

type Session = {
	room: RoomBuilder.Room,
	slot: number,
	round: number,
	phase: string,
	message: string,
	puzzle: Puzzle.State,
	lastAction: number,
	version: number,
	connections: { RBXScriptConnection },
}
local sessions: { [Player]: Session } = {}
local occupied: { [number]: boolean } = {}

local function publish(player: Player, session: Session)
	local notes = {}
	for index = 1, 3 do
		notes[index] = if session.puzzle.seen[index]
			then clueNames[index] .. ": The safe exit is " .. session.puzzle.statements[index] .. "."
			else clueNames[index] .. ": Not inspected"
	end
	-- One atomic value avoids partial UI updates and missed RemoteEvent snapshots.
	player:SetAttribute(SNAPSHOT_ATTRIBUTE, HttpService:JSONEncode({
		round = session.round, total = ROUND_COUNT, phase = session.phase,
		message = session.message, notes = notes, seen = Puzzle.countSeen(session.puzzle),
	}))
end

local function setPrompts(session: Session)
	for _, item in ipairs(session.room.clues) do
		item.Enabled = session.phase == "Explore"
	end
	for _, item in pairs(session.room.doors) do
		item.Enabled = session.phase == "Explore"
	end
	session.room.replay.Enabled = session.phase == "Won"
end

local function newPuzzle(): Puzzle.State
	return Puzzle.new(if random:NextInteger(1, 2) == 1 then "BLUE" else "AMBER", random:NextInteger(1, 3))
end

local function moveCharacter(player: Player, session: Session, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root or not root:IsA("BasePart") or sessions[player] ~= session or player.Character ~= character then
		return
	end
	character:PivotTo(session.room.spawn)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function beginRound(player: Player, session: Session)
	session.version += 1
	session.puzzle = newPuzzle()
	session.phase = "Explore"
	session.message = "One prop is lying. Two tell the truth. Inspect all three, then trust the majority."
	setPrompts(session)
	publish(player, session)
	if player.Character then
		task.spawn(moveCharacter, player, session, player.Character)
	end
end

-- Only registered server-owned prompts enter this function. Never accept a client answer.
local function allowed(player: Player, session: Session, item: ProximityPrompt): boolean
	if sessions[player] ~= session or not item.Enabled then return false end
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	local target = item.Parent
	if not character or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return false end
	if not target or not target:IsA("BasePart") or not target.Anchored or not target:IsDescendantOf(session.room.model) then return false end
	local delta = target.Position - root.Position
	if delta.Magnitude > 10 then return false end
	local parameters = RaycastParams.new()
	parameters.FilterType = Enum.RaycastFilterType.Exclude
	parameters.FilterDescendantsInstances = { character }
	local hit = workspace:Raycast(root.Position, delta, parameters)
	if hit and hit.Instance ~= target then return false end
	local now = os.clock()
	if now - session.lastAction < 0.25 then return false end
	session.lastAction = now
	return true
end

local function choose(player: Player, session: Session, door: string)
	local result = Puzzle.choose(session.puzzle, door)
	if result == "locked" then
		session.message = "Inspect all three props first. Your notebook is incomplete."
		publish(player, session)
		return
	end
	if result ~= "correct" and result ~= "wrong" then return end
	session.phase = "Resolving" -- Lock synchronously before scheduling any work.
	session.message = if result == "correct" then "Caught the lie! That exit is safe." else "Bamboozled! Read your notebook and try the other exit."
	setPrompts(session)
	publish(player, session)
	local version = session.version
	task.delay(2, function()
		if sessions[player] ~= session or session.version ~= version then return end
		if result == "wrong" then
			session.phase = "Explore" -- Keep the same puzzle and clues on a wrong answer.
		elseif session.round == ROUND_COUNT then
			session.phase = "Won"
			session.message = "YOU OUTSMARTED THE ROOM! Use the Encore button to play again."
		else
			session.round += 1
			beginRound(player, session)
			return
		end
		setPrompts(session)
		publish(player, session)
	end)
end

local function addPlayer(player: Player)
	if sessions[player] then return end
	local slot: number? = nil
	for index = 1, CAPACITY do
		if not occupied[index] then slot = index; break end
	end
	if not slot then
		player:Kick("This prototype has 12 rooms. Please join a different server.")
		return
	end
	occupied[slot] = true
	local room = RoomBuilder.build(Vector3.new((slot - 1) * 96, 48, 0), player.UserId)
	local session: Session = {
		room = room, slot = slot, round = 1, phase = "Explore", message = "",
		puzzle = newPuzzle(), lastAction = -math.huge, version = 0, connections = {},
	}
	sessions[player] = session
	room.model.Parent = rooms
	for index, item in ipairs(room.clues) do
		table.insert(session.connections, item.Triggered:Connect(function(actor)
			if actor ~= player or session.phase ~= "Explore" or not allowed(player, session, item) then return end
			Puzzle.inspect(session.puzzle, index)
			session.message = clueNames[index] .. " says: The safe exit is " .. session.puzzle.statements[index] .. "."
			publish(player, session)
		end))
	end
	for door, item in pairs(room.doors) do
		table.insert(session.connections, item.Triggered:Connect(function(actor)
			if actor ~= player or session.phase ~= "Explore" or not allowed(player, session, item) then return end
			choose(player, session, door)
		end))
	end
	table.insert(session.connections, room.replay.Triggered:Connect(function(actor)
		if actor ~= player or session.phase ~= "Won" or not allowed(player, session, room.replay) then return end
		session.round = 1
		beginRound(player, session)
	end))
	table.insert(session.connections, player.CharacterAdded:Connect(function(character)
		moveCharacter(player, session, character)
	end))
	beginRound(player, session)
end

Players.PlayerRemoving:Connect(function(player)
	local session = sessions[player]
	if not session then return end
	sessions[player] = nil
	occupied[session.slot] = nil
	for _, connection in ipairs(session.connections) do connection:Disconnect() end
	session.room.model:Destroy()
end)
Players.PlayerAdded:Connect(addPlayer)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(addPlayer, player) end
