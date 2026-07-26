local TweenService = game:GetService("TweenService")

local RaceController = {}

local remotes, gui, stableController
local selectedHorseId = nil

function RaceController.Init(guiRefs, remotesFolder, stableCtrl)
	gui = guiRefs
	remotes = remotesFolder
	stableController = stableCtrl

	gui.RaceJoinButton.MouseButton1Click:Connect(function()
		RaceController._Join()
	end)

	gui.RaceLeaveButton.MouseButton1Click:Connect(function()
		remotes.LeaveRaceQueue:InvokeServer()
		gui.RaceStatusLabel.Text = "エントリーを取り消しました"
	end)

	remotes.RaceResult.OnClientEvent:Connect(function(raceData)
		RaceController._PlayRace(raceData)
	end)

	stableController.Updated:Connect(function()
		RaceController._RenderHorseSelector()
	end)
end

function RaceController._Join()
	if not selectedHorseId then
		gui.RaceStatusLabel.Text = "出走する馬を選択してください"
		return
	end

	local ok, result = remotes.JoinRaceQueue:InvokeServer(selectedHorseId)
	if ok then
		gui.RaceStatusLabel.Text = ("待機中... (現在 %d 頭エントリー)"):format(result.QueueSize)
	else
		gui.RaceStatusLabel.Text = tostring(result)
	end
end

function RaceController._RenderHorseSelector()
	local HorseCard = require(script.Parent.Parent.UI.HorseCard)

	for _, child in ipairs(gui.RaceHorseList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, horse in ipairs(stableController.GetHorses()) do
		if not horse.Retired then
			local card = HorseCard.Create(horse, { ShowSelect = true, SelectText = "この馬で出走" })
			card.Parent = gui.RaceHorseList
			local selectButton = card:FindFirstChild("SelectButton", true)
			if selectButton then
				selectButton.MouseButton1Click:Connect(function()
					selectedHorseId = horse.Id
					gui.RaceStatusLabel.Text = horse.Name .. " を選択中"
				end)
			end
		end
	end
end

local function buildTrackRow(layoutOrder, result, yourHorseId)
	local row = Instance.new("Frame")
	row.Name = "Row_" .. result.HorseId
	row.Size = UDim2.new(1, 0, 0, 26)
	row.LayoutOrder = layoutOrder
	row.BackgroundTransparency = 1

	local isYou = result.HorseId == yourHorseId

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 150, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(235, 235, 240)
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = result.Name .. (isYou and " (あなた)" or "")
	label.Parent = row

	local trackBg = Instance.new("Frame")
	trackBg.Name = "TrackBg"
	trackBg.Size = UDim2.new(1, -160, 1, -6)
	trackBg.Position = UDim2.new(0, 160, 0, 3)
	trackBg.BackgroundColor3 = Color3.fromRGB(44, 48, 58)
	trackBg.BorderSizePixel = 0
	trackBg.Parent = row
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = trackBg

	local runner = Instance.new("Frame")
	runner.Name = "Runner"
	runner.Size = UDim2.new(0, 16, 1, 0)
	runner.BackgroundColor3 = isYou and Color3.fromRGB(255, 176, 59) or Color3.fromRGB(99, 178, 255)
	runner.BorderSizePixel = 0
	runner.Parent = trackBg
	local runnerCorner = Instance.new("UICorner")
	runnerCorner.CornerRadius = UDim.new(1, 0)
	runnerCorner.Parent = runner

	return row, trackBg, runner
end

function RaceController._PlayRace(raceData)
	for _, child in ipairs(gui.RaceTrack:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	gui.RaceResultLabel.Text = ""
	gui.RaceStatusLabel.Text = "レース中..."

	local bars = {}
	local maxTime = 0
	for i, result in ipairs(raceData.Results) do
		local row, trackBg, runner = buildTrackRow(i, result, raceData.YourHorseId)
		row.Parent = gui.RaceTrack
		bars[result.HorseId] = { TrackBg = trackBg, Runner = runner, Result = result }
		maxTime = math.max(maxTime, result.Time)
	end

	task.wait() -- let layout settle so AbsoluteSize is valid before animating

	for _, bar in pairs(bars) do
		task.spawn(function()
			local elapsed = 0
			for _, checkpoint in ipairs(bar.Result.Checkpoints) do
				local dt = math.max(checkpoint.Time - elapsed, 0.05)
				elapsed = checkpoint.Time
				local trackWidth = bar.TrackBg.AbsoluteSize.X - bar.Runner.AbsoluteSize.X
				local targetX = trackWidth * checkpoint.Progress
				local tween = TweenService:Create(
					bar.Runner,
					TweenInfo.new(dt * 0.6, Enum.EasingStyle.Linear),
					{ Position = UDim2.new(0, targetX, 0, 0) }
				)
				tween:Play()
				task.wait(dt * 0.6)
			end
		end)
	end

	task.delay(maxTime * 0.6 + 0.5, function()
		gui.RaceStatusLabel.Text = ("レース結果 (距離 %dm)"):format(raceData.Distance)
		local lines = {}
		for _, result in ipairs(raceData.Results) do
			table.insert(lines, ("%d着  %s"):format(result.Place, result.Name))
		end
		gui.RaceResultLabel.Text = table.concat(lines, "\n")
		stableController.Refresh()
	end)
end

return RaceController
