--!strict
-- Pure puzzle rules. Keep this module on the server: it contains the answer.
local Puzzle = {}

export type Door = "BLUE" | "AMBER"
export type State = {
	safeDoor: Door,
	statements: { Door },
	seen: { [number]: boolean },
}

function Puzzle.new(safeDoor: Door, liar: number): State
	assert(safeDoor == "BLUE" or safeDoor == "AMBER", "Unknown exit")
	assert(liar >= 1 and liar <= 3 and liar % 1 == 0, "Invalid liar index")
	local other: Door = if safeDoor == "BLUE" then "AMBER" else "BLUE"
	local statements: { Door } = { safeDoor, safeDoor, safeDoor }
	statements[liar] = other
	return { safeDoor = safeDoor, statements = statements, seen = {} }
end

function Puzzle.inspect(state: State, index: number): boolean
	if index % 1 ~= 0 or index < 1 or index > 3 then
		return false
	end
	local firstVisit = not state.seen[index]
	state.seen[index] = true
	return firstVisit
end

function Puzzle.countSeen(state: State): number
	local count = 0
	for index = 1, 3 do
		if state.seen[index] then
			count += 1
		end
	end
	return count
end

function Puzzle.choose(state: State, door: string): string
	if door ~= "BLUE" and door ~= "AMBER" then
		return "invalid"
	end
	if Puzzle.countSeen(state) < 3 then
		return "locked"
	end
	return if door == state.safeDoor then "correct" else "wrong"
end

return Puzzle
