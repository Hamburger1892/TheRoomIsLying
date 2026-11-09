--!strict
-- In Studio's Command Bar, run this module's returned function with Puzzle.
-- Example: require(pathToSpec)(require(game.ServerScriptService.TheRoomIsLying.Puzzle))
return function(Puzzle)
	local assertions = 0
	local function expect(condition: boolean, message: string)
		assertions += 1
		assert(condition, message)
	end
	for _, safeDoor in ipairs({ "BLUE", "AMBER" }) do
		for liar = 1, 3 do
			local state = Puzzle.new(safeDoor, liar)
			local truths = 0
			for index = 1, 3 do
				if state.statements[index] == safeDoor then truths += 1 end
			end
			expect(truths == 2, "Every puzzle needs exactly two truthful clues")
			expect(state.statements[liar] ~= safeDoor, "Selected liar must lie")
			expect(Puzzle.choose(state, safeDoor) == "locked", "Guessing before clues must be locked")
			expect(not Puzzle.inspect(state, 0), "Reject index zero")
			expect(not Puzzle.inspect(state, 4), "Reject out-of-range index")
			expect(not Puzzle.inspect(state, 1.5), "Reject fractional index")
			expect(Puzzle.inspect(state, 1), "First inspection should count")
			expect(not Puzzle.inspect(state, 1), "Duplicate inspection must not count twice")
			expect(Puzzle.countSeen(state) == 1, "Duplicate clues must not unlock doors")
			Puzzle.inspect(state, 2)
			expect(Puzzle.choose(state, safeDoor) == "locked", "Two clues are insufficient")
			Puzzle.inspect(state, 3)
			expect(Puzzle.countSeen(state) == 3, "Three unique clues complete the notebook")
			expect(Puzzle.choose(state, safeDoor) == "correct", "Majority exit must win")
			local other = if safeDoor == "BLUE" then "AMBER" else "BLUE"
			expect(Puzzle.choose(state, other) == "wrong", "Minority exit must lose")
			expect(Puzzle.choose(state, "GREEN") == "invalid", "Reject unknown exits")
			expect(Puzzle.countSeen(state) == 3, "Wrong choices should preserve clues for retry")
		end
	end
	local first = Puzzle.new("BLUE", 1)
	local second = Puzzle.new("AMBER", 2)
	Puzzle.inspect(first, 1)
	expect(Puzzle.countSeen(second) == 0, "Player sessions must not share clue state")
	local fresh = Puzzle.new("BLUE", 3)
	expect(Puzzle.countSeen(fresh) == 0, "New rounds/replay must start with no discovered clues")
	local ok = pcall(function() Puzzle.new("BLUE", 0) end)
	expect(not ok, "Reject invalid content configuration")
	return string.format("Puzzle: %d assertions passed across all six puzzle configurations", assertions)
end
