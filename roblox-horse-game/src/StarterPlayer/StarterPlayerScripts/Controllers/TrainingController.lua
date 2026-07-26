local TrainingController = {}

local remotes, gui, stableController
local selectedHorseId = nil

local STAT_ORDER = { "Speed", "Stamina", "Power", "Guts", "Wisdom", "Rest" }

function TrainingController.Init(guiRefs, remotesFolder, stableCtrl)
	gui = guiRefs
	remotes = remotesFolder
	stableController = stableCtrl

	for _, statName in ipairs(STAT_ORDER) do
		local button = gui.TrainingButtons[statName]
		if button then
			button.MouseButton1Click:Connect(function()
				TrainingController._DoTrain(statName)
			end)
		end
	end

	stableController.Updated:Connect(function()
		TrainingController._RenderHorseSelector()
	end)
end

function TrainingController._RenderHorseSelector()
	local HorseCard = require(script.Parent.Parent.UI.HorseCard)

	for _, child in ipairs(gui.TrainingHorseList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, horse in ipairs(stableController.GetHorses()) do
		if not horse.Retired then
			local card = HorseCard.Create(horse, { ShowSelect = true, SelectText = "選択" })
			card.Parent = gui.TrainingHorseList

			local selectButton = card:FindFirstChild("SelectButton", true)
			if selectButton then
				selectButton.MouseButton1Click:Connect(function()
					selectedHorseId = horse.Id
					gui.TrainingSelectedLabel.Text = "調教対象: " .. horse.Name
				end)
			end
		end
	end
end

function TrainingController._DoTrain(statName)
	if not selectedHorseId then
		gui.TrainingLogLabel.Text = "先に馬を選択してください"
		return
	end

	local ok, result = remotes.TrainHorse:InvokeServer(selectedHorseId, statName)
	if not ok then
		gui.TrainingLogLabel.Text = tostring(result)
		return
	end

	if result.Type == "Rest" then
		gui.TrainingLogLabel.Text = ("休養させました。エネルギー: %d"):format(result.Energy)
	elseif result.Type == "Injury" then
		gui.TrainingLogLabel.Text = ("⚠️ %s の調教中にケガをしてしまいました…コンディション悪化"):format(statName)
	else
		gui.TrainingLogLabel.Text = ("%s +%d (現在値 %d) / エネルギー %d"):format(
			result.StatName,
			result.Gain,
			result.NewValue,
			result.Energy
		)
	end

	stableController.Refresh()
end

return TrainingController
