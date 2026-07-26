local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local HorseStore = DataStoreService:GetDataStore("HorseRanchLegend_PlayerData_v1")
local AUTOSAVE_INTERVAL = 120

local DataService = {}
local cache = {} -- [userId] = data table

local function defaultData()
	return {
		Coins = 1000,
		Horses = {},
		Stats = { TotalRaces = 0, TotalWins = 0 },
	}
end

function DataService.Load(player)
	local key = "player_" .. player.UserId
	local success, data = pcall(function()
		return HorseStore:GetAsync(key)
	end)

	cache[player.UserId] = (success and data) or defaultData()
	return cache[player.UserId]
end

function DataService.Get(player)
	return cache[player.UserId]
end

function DataService.Save(player)
	local data = cache[player.UserId]
	if not data then
		return
	end

	local key = "player_" .. player.UserId
	local success, err = pcall(function()
		HorseStore:SetAsync(key, data)
	end)

	if not success then
		warn(("[DataService] Failed to save data for %s: %s"):format(player.Name, tostring(err)))
	end
end

function DataService.Release(player)
	DataService.Save(player)
	cache[player.UserId] = nil
end

function DataService.Init()
	for _, player in ipairs(Players:GetPlayers()) do
		DataService.Load(player)
	end

	Players.PlayerAdded:Connect(function(player)
		DataService.Load(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		DataService.Release(player)
	end)

	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)
			for _, player in ipairs(Players:GetPlayers()) do
				DataService.Save(player)
			end
		end
	end)

	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			DataService.Save(player)
		end
	end)
end

return DataService
