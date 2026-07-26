local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Modules.Constants)
local HorseFactory = require(ReplicatedStorage.Modules.HorseFactory)
local RaceSimulator = require(ReplicatedStorage.Modules.RaceSimulator)
local StableService = require(script.Parent.StableService)

local RaceService = {}

local QUEUE_WAIT_TIME = 20
local MIN_FIELD_SIZE = 4 -- NPCs fill the gap so a race always feels populated
local MAX_RACERS = 8
local ENERGY_COST_PER_RACE = 15

local ALL_DISTANCES = {
	Constants.RaceDistances.Sprint,
	Constants.RaceDistances.Mile,
	Constants.RaceDistances.Middle,
	Constants.RaceDistances.Long,
}

local queue = {} -- array of { Player, Horse }
local queueOpenAt = nil
local remotes

function RaceService.Init(remoteTable)
	remotes = remoteTable
end

local function removeFromQueue(player)
	for i = #queue, 1, -1 do
		if queue[i].Player == player then
			table.remove(queue, i)
		end
	end
end

function RaceService.Join(player, horseId)
	local horse = StableService.FindHorse(player, horseId)
	if not horse then
		return false, "馬が見つかりません"
	end
	if horse.Retired then
		return false, "この馬は引退しています"
	end
	if horse.Energy < 10 then
		return false, "エネルギーが不足しています。休養させてください"
	end

	removeFromQueue(player)
	table.insert(queue, { Player = player, Horse = horse })

	if not queueOpenAt then
		queueOpenAt = os.clock()
		task.spawn(RaceService._RunQueueTimer, queueOpenAt)
	end

	if #queue >= MAX_RACERS then
		RaceService._StartRace()
	end

	return true, { QueueSize = #queue }
end

function RaceService.Leave(player)
	removeFromQueue(player)
	return true
end

function RaceService._RunQueueTimer(startedAt)
	while os.clock() - startedAt < QUEUE_WAIT_TIME and #queue < MAX_RACERS do
		task.wait(1)
		if queueOpenAt ~= startedAt then
			return -- a race already started elsewhere and reset the timer
		end
	end

	if queueOpenAt == startedAt then
		RaceService._StartRace()
	end
end

function RaceService._StartRace()
	local entrants = {}
	for _, entry in ipairs(queue) do
		table.insert(entrants, {
			HorseId = entry.Horse.Id,
			Name = entry.Horse.Name,
			Stats = entry.Horse.Stats,
			Condition = entry.Horse.Condition,
		})
	end

	local npcCount = math.max(0, MIN_FIELD_SIZE - #entrants)
	for _ = 1, npcCount do
		local npcHorse = HorseFactory.CreateFoundationHorse("NPC・" .. HorseFactory.GenerateRandomName())
		table.insert(entrants, {
			HorseId = npcHorse.Id,
			Name = npcHorse.Name,
			Stats = npcHorse.Stats,
			Condition = npcHorse.Condition,
		})
	end

	local distance = ALL_DISTANCES[math.random(#ALL_DISTANCES)]
	local results = RaceSimulator.SimulateRace(entrants, distance)

	for _, entry in ipairs(queue) do
		local horse = entry.Horse
		horse.Races += 1
		horse.Energy = math.max(0, horse.Energy - ENERGY_COST_PER_RACE)

		for _, result in ipairs(results) do
			if result.HorseId == horse.Id then
				if result.Place == 1 then
					horse.Wins += 1
				end
				table.insert(horse.RaceHistory, { Place = result.Place, Distance = distance, Time = result.Time })
				if #horse.RaceHistory > 20 then
					table.remove(horse.RaceHistory, 1)
				end
				break
			end
		end
	end

	for _, entry in ipairs(queue) do
		if remotes and remotes.RaceResult then
			remotes.RaceResult:FireClient(entry.Player, {
				Distance = distance,
				Results = results,
				YourHorseId = entry.Horse.Id,
			})
		end
	end

	queue = {}
	queueOpenAt = nil
end

return RaceService
