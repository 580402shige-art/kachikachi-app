local Players = game:GetService("Players")

local Services = script.Parent.Services
local RemotesSetup = require(Services.RemotesSetup)
local DataService = require(Services.DataService)
local StableService = require(Services.StableService)
local TrainingService = require(Services.TrainingService)
local BreedingService = require(Services.BreedingService)
local RaceService = require(Services.RaceService)

local remotes = RemotesSetup.Init()
DataService.Init()
RaceService.Init(remotes)

Players.PlayerAdded:Connect(function(player)
	StableService.EnsureStarterHorses(player)
end)

remotes.GetStableData.OnServerInvoke = function(player)
	StableService.EnsureStarterHorses(player)
	local data = DataService.Get(player)
	if not data then
		return { Coins = 0, Horses = {} }
	end
	return { Coins = data.Coins, Horses = data.Horses }
end

remotes.TrainHorse.OnServerInvoke = function(player, horseId, statName)
	return TrainingService.Train(player, horseId, statName)
end

remotes.BreedHorses.OnServerInvoke = function(player, stallionId, mareId)
	return BreedingService.Breed(player, stallionId, mareId)
end

remotes.JoinRaceQueue.OnServerInvoke = function(player, horseId)
	return RaceService.Join(player, horseId)
end

remotes.LeaveRaceQueue.OnServerInvoke = function(player)
	return RaceService.Leave(player)
end

remotes.RetireHorse.OnServerInvoke = function(player, horseId)
	local horse = StableService.RetireHorse(player, horseId)
	return horse ~= nil, horse
end
