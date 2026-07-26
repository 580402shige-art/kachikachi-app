local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Modules.Signal)

local StableController = {}
StableController.Updated = Signal.new()

local remotes, gui
local horses = {}
local coins = 0

function StableController.Init(guiRefs, remotesFolder)
	gui = guiRefs
	remotes = remotesFolder
end

function StableController.Refresh()
	local data = remotes.GetStableData:InvokeServer()
	if not data then
		return
	end
	horses = data.Horses
	coins = data.Coins
	StableController._Render()
	StableController.Updated:Fire(horses)
end

function StableController.GetHorses()
	return horses
end

function StableController.GetHorse(horseId)
	for _, horse in ipairs(horses) do
		if horse.Id == horseId then
			return horse
		end
	end
	return nil
end

function StableController._Render()
	gui.CoinsLabel.Text = ("💰 %d G"):format(coins)

	for _, child in ipairs(gui.StableList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local HorseCard = require(script.Parent.Parent.UI.HorseCard)
	for _, horse in ipairs(horses) do
		local card = HorseCard.Create(horse, { ShowRetire = true })
		card.Parent = gui.StableList

		local retireButton = card:FindFirstChild("RetireButton", true)
		if retireButton then
			retireButton.MouseButton1Click:Connect(function()
				local ok = remotes.RetireHorse:InvokeServer(horse.Id)
				if ok then
					StableController.Refresh()
				end
			end)
		end
	end
end

return StableController
