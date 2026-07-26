local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Modules.Constants)
local Genetics = require(ReplicatedStorage.Modules.Genetics)
local HorseFactory = require(ReplicatedStorage.Modules.HorseFactory)
local StableService = require(script.Parent.StableService)

local BreedingService = {}

function BreedingService.Breed(player, stallionId, mareId)
	local stallion = StableService.FindHorse(player, stallionId)
	local mare = StableService.FindHorse(player, mareId)

	if not stallion or not mare then
		return false, "馬が見つかりません"
	end
	if stallion.Gender ~= "Stallion" or mare.Gender ~= "Mare" then
		return false, "父馬(Stallion)と母馬(Mare)を選択してください"
	end

	-- Retired horses have already proven themselves and can breed immediately;
	-- active horses need a minimum race record first.
	if not stallion.Retired and stallion.Races < Constants.MinRacesBeforeBreeding then
		return false, ("父馬は配合には最低%d戦のレース経験が必要です"):format(Constants.MinRacesBeforeBreeding)
	end
	if not mare.Retired and mare.Races < Constants.MinRacesBeforeBreeding then
		return false, ("母馬は配合には最低%d戦のレース経験が必要です"):format(Constants.MinRacesBeforeBreeding)
	end

	local now = os.time()
	if mare.LastBredAt and (now - mare.LastBredAt) < Constants.BreedingCooldownSeconds then
		return false, "母馬はまだ配合のクールダウン中です"
	end

	local breedResult = Genetics.Breed(stallion, mare)
	local foal = HorseFactory.CreateFoal(breedResult)

	mare.LastBredAt = now
	StableService.AddHorse(player, foal)

	return true, foal
end

return BreedingService
