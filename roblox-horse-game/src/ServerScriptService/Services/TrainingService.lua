local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Modules.Constants)
local StableService = require(script.Parent.StableService)

local TrainingService = {}

local TRAINING_GAINS = {
	Speed = { min = 8, max = 16 },
	Stamina = { min = 8, max = 16 },
	Power = { min = 8, max = 16 },
	Guts = { min = 6, max = 14 },
	Wisdom = { min = 5, max = 12 },
}

local ENERGY_COST = 20
local BASE_INJURY_CHANCE = 0.05
local REST_ENERGY_RESTORE = 45

local function clamp(x, lo, hi)
	return math.max(lo, math.min(hi, x))
end

function TrainingService.Train(player, horseId, statName)
	local horse = StableService.FindHorse(player, horseId)
	if not horse then
		return false, "馬が見つかりません"
	end
	if horse.Retired then
		return false, "この馬は引退しています"
	end

	if statName == "Rest" then
		horse.Energy = clamp(horse.Energy + REST_ENERGY_RESTORE, 0, Constants.MaxEnergy)
		horse.Condition = "Good"
		return true, { Type = "Rest", Energy = horse.Energy }
	end

	local gainRange = TRAINING_GAINS[statName]
	if not gainRange then
		return false, "無効な調教種目です"
	end
	if horse.Energy < ENERGY_COST then
		return false, "エネルギーが足りません。休養させてください"
	end

	horse.Energy = clamp(horse.Energy - ENERGY_COST, 0, Constants.MaxEnergy)

	local injuryChance = BASE_INJURY_CHANCE
	if horse.Energy < 20 then
		injuryChance += 0.10
	end

	if math.random() < injuryChance then
		horse.Condition = "Bad"
		return true, { Type = "Injury", StatName = statName, Energy = horse.Energy, Condition = horse.Condition }
	end

	local gain = math.random(gainRange.min, gainRange.max)
	horse.Stats[statName] = clamp(horse.Stats[statName] + gain, 0, Constants.StatCap)

	if horse.Condition == "Bad" and math.random() < 0.3 then
		horse.Condition = "Normal"
	elseif horse.Condition == "Normal" and math.random() < 0.3 then
		horse.Condition = "Good"
	end

	return true, {
		Type = "Train",
		StatName = statName,
		Gain = gain,
		NewValue = horse.Stats[statName],
		Energy = horse.Energy,
		Condition = horse.Condition,
	}
end

return TrainingService
