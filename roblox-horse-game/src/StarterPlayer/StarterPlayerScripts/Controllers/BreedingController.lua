local BreedingController = {}

local remotes, gui, stableController
local selectedStallionId, selectedMareId = nil, nil

local function nameOf(horseId)
	if not horseId then
		return "未選択"
	end
	local horse = stableController.GetHorse(horseId)
	return horse and horse.Name or "未選択"
end

function BreedingController.Init(guiRefs, remotesFolder, stableCtrl)
	gui = guiRefs
	remotes = remotesFolder
	stableController = stableCtrl

	gui.BreedButton.MouseButton1Click:Connect(function()
		BreedingController._DoBreed()
	end)

	stableController.Updated:Connect(function()
		BreedingController._RenderSelectors()
	end)
end

local function updateSelectionLabel()
	gui.BreedingSelectionLabel.Text = ("父: %s / 母: %s"):format(nameOf(selectedStallionId), nameOf(selectedMareId))
end

function BreedingController._RenderSelectors()
	local HorseCard = require(script.Parent.Parent.UI.HorseCard)

	for _, child in ipairs(gui.StallionList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	for _, child in ipairs(gui.MareList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, horse in ipairs(stableController.GetHorses()) do
		if horse.Gender == "Stallion" then
			local card = HorseCard.Create(horse, { ShowSelect = true, SelectText = "選択" })
			card.Parent = gui.StallionList
			local selectButton = card:FindFirstChild("SelectButton", true)
			if selectButton then
				selectButton.MouseButton1Click:Connect(function()
					selectedStallionId = horse.Id
					updateSelectionLabel()
				end)
			end
		elseif horse.Gender == "Mare" then
			local card = HorseCard.Create(horse, { ShowSelect = true, SelectText = "選択" })
			card.Parent = gui.MareList
			local selectButton = card:FindFirstChild("SelectButton", true)
			if selectButton then
				selectButton.MouseButton1Click:Connect(function()
					selectedMareId = horse.Id
					updateSelectionLabel()
				end)
			end
		end
	end
end

function BreedingController._DoBreed()
	if not selectedStallionId or not selectedMareId then
		gui.BreedingResultLabel.Text = "父馬・母馬の両方を選択してください"
		return
	end

	local ok, result = remotes.BreedHorses:InvokeServer(selectedStallionId, selectedMareId)
	if not ok then
		gui.BreedingResultLabel.Text = tostring(result)
		return
	end

	gui.BreedingResultLabel.Text = ("🐴 %s が生まれました！(世代%d)"):format(result.Name, result.Generation)
	stableController.Refresh()
end

return BreedingController
