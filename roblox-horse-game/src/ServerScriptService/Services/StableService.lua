local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HorseFactory = require(ReplicatedStorage.Modules.HorseFactory)
local DataService = require(script.Parent.DataService)

local StableService = {}

-- Guarantee at least one breedable pair from the start.
function StableService.EnsureStarterHorses(player)
	local data = DataService.Get(player)
	if not data or #data.Horses > 0 then
		return
	end

	table.insert(data.Horses, HorseFactory.CreateFoundationHorse(nil, "Stallion"))
	table.insert(data.Horses, HorseFactory.CreateFoundationHorse(nil, "Mare"))
	table.insert(data.Horses, HorseFactory.CreateFoundationHorse())
end

function StableService.GetHorses(player)
	local data = DataService.Get(player)
	return data and data.Horses or {}
end

function StableService.FindHorse(player, horseId)
	for _, horse in ipairs(StableService.GetHorses(player)) do
		if horse.Id == horseId then
			return horse
		end
	end
	return nil
end

function StableService.AddHorse(player, horse)
	local data = DataService.Get(player)
	if data then
		table.insert(data.Horses, horse)
	end
end

function StableService.RetireHorse(player, horseId)
	local horse = StableService.FindHorse(player, horseId)
	if horse then
		horse.Retired = true
	end
	return horse
end

return StableService
