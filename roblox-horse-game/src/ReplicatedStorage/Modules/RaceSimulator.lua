local Constants = require(script.Parent.Constants)

local RaceSimulator = {}

-- Different distances weight stats differently: sprints reward Speed/Power,
-- long races reward Stamina/Guts. Wisdom stabilizes performance (less variance).
local DISTANCE_PROFILE = {
	[Constants.RaceDistances.Sprint] = { Speed = 0.45, Stamina = 0.15, Power = 0.30, Guts = 0.05, Wisdom = 0.05 },
	[Constants.RaceDistances.Mile] = { Speed = 0.35, Stamina = 0.25, Power = 0.20, Guts = 0.10, Wisdom = 0.10 },
	[Constants.RaceDistances.Middle] = { Speed = 0.25, Stamina = 0.35, Power = 0.15, Guts = 0.15, Wisdom = 0.10 },
	[Constants.RaceDistances.Long] = { Speed = 0.15, Stamina = 0.45, Power = 0.10, Guts = 0.20, Wisdom = 0.10 },
}

local CHECKPOINT_COUNT = 10

local function generateCheckpoints(finalTime)
	local checkpoints = {}
	for i = 1, CHECKPOINT_COUNT do
		local t = (finalTime / CHECKPOINT_COUNT) * i
		local jitter = (math.random() * 2 - 1) * (finalTime * 0.01)
		table.insert(checkpoints, { Progress = i / CHECKPOINT_COUNT, Time = math.max(0, t + jitter) })
	end
	checkpoints[CHECKPOINT_COUNT].Time = finalTime
	return checkpoints
end

-- entrants: array of { HorseId, Name, Stats, Condition }
function RaceSimulator.SimulateRace(entrants, distance)
	local profile = DISTANCE_PROFILE[distance] or DISTANCE_PROFILE[Constants.RaceDistances.Mile]
	local results = {}

	for _, entrant in ipairs(entrants) do
		local stats = entrant.Stats
		local power = stats.Speed * profile.Speed
			+ stats.Stamina * profile.Stamina
			+ stats.Power * profile.Power
			+ stats.Guts * profile.Guts
			+ stats.Wisdom * profile.Wisdom

		local conditionMultiplier = 1.0
		if entrant.Condition == "Good" then
			conditionMultiplier = 1.05
		elseif entrant.Condition == "Bad" then
			conditionMultiplier = 0.9
		end

		local varianceRange = 0.18 - (stats.Wisdom / Constants.StatCap) * 0.10
		local randomFactor = 1 + (math.random() * 2 - 1) * varianceRange
		local finalPower = power * conditionMultiplier * randomFactor

		local baseTime = distance / 16.6
		local time = baseTime * (1000 / (finalPower + 500))

		table.insert(results, {
			HorseId = entrant.HorseId,
			Name = entrant.Name,
			Time = time,
			Checkpoints = generateCheckpoints(time),
		})
	end

	table.sort(results, function(a, b)
		return a.Time < b.Time
	end)

	for i, result in ipairs(results) do
		result.Place = i
	end

	return results
end

return RaceSimulator
