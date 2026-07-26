local HttpService = game:GetService("HttpService")
local Constants = require(script.Parent.Constants)

local HorseFactory = {}

local NAME_PART_A = {
	"ゴールド", "シルバー", "サンダー", "ブレイズ", "スター", "ミスティ",
	"ノーブル", "レジェンド", "ウィンド", "シャドウ", "クリムゾン", "オーロラ",
}
local NAME_PART_B = {
	"キング", "クイーン", "ダッシュ", "フレイム", "ウェイブ", "スピリット",
	"ソニック", "エンペラー", "ドリーム", "バレット", "ギャロップ", "コメット",
}

function HorseFactory.GenerateRandomName()
	return NAME_PART_A[math.random(#NAME_PART_A)] .. NAME_PART_B[math.random(#NAME_PART_B)]
end

local function baseHorse(name, gender, stats, generation, bloodline)
	return {
		Id = HttpService:GenerateGUID(false),
		Name = name or HorseFactory.GenerateRandomName(),
		Gender = gender or (math.random() < 0.5 and "Stallion" or "Mare"),
		Stats = stats,
		Generation = generation or 0,
		Bloodline = bloodline or { Sire = "---", Dam = "---" },
		Energy = Constants.MaxEnergy,
		Condition = "Good", -- Good | Normal | Bad
		RaceHistory = {},
		Wins = 0,
		Races = 0,
		Retired = false,
		LastBredAt = nil,
		CreatedAt = os.time(),
	}
end

function HorseFactory.CreateFoundationHorse(name, gender)
	local stats = {}
	for _, statName in ipairs(Constants.StatNames) do
		stats[statName] = math.random(Constants.FoundationStatMin, Constants.FoundationStatMax)
	end
	return baseHorse(name, gender, stats, 0, nil)
end

function HorseFactory.CreateFoal(breedResult, name)
	return baseHorse(name, nil, breedResult.Stats, breedResult.Generation, breedResult.Bloodline)
end

return HorseFactory
