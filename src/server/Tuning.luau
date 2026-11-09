--!strict
-- Read once per round so pacing never changes halfway through a round.
local RunService = game:GetService("RunService")
local defaults = {
	MemorizeSeconds = 15, BlackoutSeconds = 2, VoteSeconds = 10, ResultsSeconds = 5,
	ChangeChance = 0.7, CorrectPoints = 100, CorrectCoins = 10,
}
local limits = {
	MemorizeSeconds = { 3, 60 }, BlackoutSeconds = { 1, 5 }, VoteSeconds = { 3, 60 },
	ResultsSeconds = { 2, 15 }, ChangeChance = { 0, 1 }, CorrectPoints = { 1, 1000 }, CorrectCoins = { 0, 100 },
}
local snapshot: any = nil
-- Optional live balance support. Off by default; no cloud setup is required.
if script:GetAttribute("UseExperienceConfigs") == true then
	task.spawn(function()
		local ok, result = pcall(function() return game:GetService("ConfigService"):GetConfigAsync() end)
		if ok then
			snapshot = result
			snapshot.UpdateAvailable:Connect(function() pcall(function() snapshot:Refresh() end) end)
		else
			warn("[TRIL] Experience Configs unavailable; using local defaults")
		end
	end)
end
local Tuning = {}
function Tuning.get()
	local values = table.clone(defaults)
	for key, bounds in pairs(limits) do
		local value = nil
		if snapshot then
			local ok, result = pcall(function() return snapshot:GetValue("TRIL_" .. key) end)
			if ok then value = result end
		end
		-- Studio-only test overrides never change published production pacing.
		if RunService:IsStudio() and script:GetAttribute(key) ~= nil then value = script:GetAttribute(key) end
		if typeof(value) == "number" and value == value then values[key] = math.clamp(value, bounds[1], bounds[2]) end
	end
	return values
end
return Tuning
