local Players = game:GetService("Players")
local Theme = require(script.Parent.Theme)

local create = Theme.Create

local UIBuilder = {}

local TAB_ORDER = { "Stable", "Training", "Breeding", "Race" }
local TAB_LABELS = {
	Stable = "🏠 厩舎",
	Training = "💪 調教",
	Breeding = "🧬 配合",
	Race = "🏁 レース",
}

local function scrollList(parent, name)
	local scroller = create("ScrollingFrame", {
		Name = name,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = parent,
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = scroller,
	})
	create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent = scroller,
	})
	return scroller
end

function UIBuilder.Build()
	local player = Players.LocalPlayer
	local gui = {}

	local screenGui = create("ScreenGui", {
		Name = "HorseRanchUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = player:WaitForChild("PlayerGui"),
	})
	gui.ScreenGui = screenGui

	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 920, 0, 600),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = main })

	-- Top bar
	local topBar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = main,
	})
	create("TextLabel", {
		Size = UDim2.new(1, -220, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "🐴 ホースランチ・レジェンド",
		TextColor3 = Theme.Text,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})
	gui.CoinsLabel = create("TextLabel", {
		Name = "CoinsLabel",
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(1, -220, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "💰 0 G",
		TextColor3 = Theme.Accent,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = topBar,
	})

	-- Tab bar
	local tabBar = create("Frame", {
		Name = "TabBar",
		Size = UDim2.new(1, -40, 0, 40),
		Position = UDim2.new(0, 20, 0, 50),
		BackgroundTransparency = 1,
		Parent = main,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabBar,
	})

	local contentFrame = create("Frame", {
		Name = "ContentFrame",
		Size = UDim2.new(1, -40, 1, -110),
		Position = UDim2.new(0, 20, 0, 100),
		BackgroundTransparency = 1,
		Parent = main,
	})

	local tabButtons = {}
	local pages = {}

	local function setActiveTab(tabName)
		for name, page in pairs(pages) do
			page.Visible = (name == tabName)
		end
		for name, button in pairs(tabButtons) do
			if name == tabName then
				button.BackgroundColor3 = Theme.Accent
				button.TextColor3 = Color3.fromRGB(30, 24, 10)
			else
				button.BackgroundColor3 = Theme.Panel
				button.TextColor3 = Theme.SubText
			end
		end
	end

	for i, tabName in ipairs(TAB_ORDER) do
		local button = create("TextButton", {
			Name = tabName .. "Tab",
			Size = UDim2.new(0, 130, 1, 0),
			LayoutOrder = i,
			BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = TAB_LABELS[tabName],
			TextColor3 = Theme.SubText,
			TextSize = 15,
			Parent = tabBar,
		})
		create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = button })
		button.MouseButton1Click:Connect(function()
			setActiveTab(tabName)
		end)
		tabButtons[tabName] = button

		local page = create("Frame", {
			Name = tabName .. "Page",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = contentFrame,
		})
		pages[tabName] = page
	end

	-- Stable page: single scrolling list of all owned horses
	gui.StableList = scrollList(pages.Stable, "StableList")

	-- Training page: horse selector (left) + controls (right)
	local trainingLeft = create("Frame", {
		Size = UDim2.new(0, 360, 1, 0),
		BackgroundTransparency = 1,
		Parent = pages.Training,
	})
	gui.TrainingHorseList = scrollList(trainingLeft, "TrainingHorseList")

	local trainingRight = create("Frame", {
		Size = UDim2.new(1, -376, 1, 0),
		Position = UDim2.new(0, 376, 0, 0),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = pages.Training,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = trainingRight })
	create("UIPadding", {
		PaddingTop = UDim.new(0, 16),
		PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
		Parent = trainingRight,
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
		Parent = trainingRight,
	})

	gui.TrainingSelectedLabel = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "調教対象: 未選択",
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		Parent = trainingRight,
	})

	local trainButtonsGrid = create("Frame", {
		Size = UDim2.new(1, 0, 0, 130),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = trainingRight,
	})
	create("UIGridLayout", {
		CellSize = UDim2.new(0, 150, 0, 40),
		CellPadding = UDim2.new(0, 10, 0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = trainButtonsGrid,
	})

	gui.TrainingButtons = {}
	local trainingOptions = { "Speed", "Stamina", "Power", "Guts", "Wisdom", "Rest" }
	local trainingLabels = {
		Speed = "🏃 スピード調教",
		Stamina = "🫁 スタミナ調教",
		Power = "💪 パワー調教",
		Guts = "🔥 根性調教",
		Wisdom = "🧠 賢さ調教",
		Rest = "😴 休養",
	}
	for i, statName in ipairs(trainingOptions) do
		local button = create("TextButton", {
			Name = statName .. "Button",
			LayoutOrder = i,
			BackgroundColor3 = statName == "Rest" and Theme.PanelLight or Theme.Accent,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = trainingLabels[statName],
			TextColor3 = statName == "Rest" and Theme.Text or Color3.fromRGB(30, 24, 10),
			TextSize = 14,
			Parent = trainButtonsGrid,
		})
		create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = button })
		gui.TrainingButtons[statName] = button
	end

	gui.TrainingLogLabel = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, -180),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "調教結果がここに表示されます",
		TextColor3 = Theme.SubText,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		LayoutOrder = 3,
		Parent = trainingRight,
	})

	-- Breeding page: stallion list + mare list + breed button/result
	local breedingTop = create("Frame", {
		Size = UDim2.new(1, 0, 1, -90),
		BackgroundTransparency = 1,
		Parent = pages.Breeding,
	})
	local stallionColumn = create("Frame", {
		Size = UDim2.new(0.5, -8, 1, 0),
		BackgroundTransparency = 1,
		Parent = breedingTop,
	})
	create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "♂ 父馬候補",
		TextColor3 = Theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = stallionColumn,
	})
	local stallionListArea = create("Frame", {
		Size = UDim2.new(1, 0, 1, -28),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundTransparency = 1,
		Parent = stallionColumn,
	})
	gui.StallionList = scrollList(stallionListArea, "StallionList")

	local mareColumn = create("Frame", {
		Size = UDim2.new(0.5, -8, 1, 0),
		Position = UDim2.new(0.5, 8, 0, 0),
		BackgroundTransparency = 1,
		Parent = breedingTop,
	})
	create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "♀ 母馬候補",
		TextColor3 = Theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = mareColumn,
	})
	local mareListArea = create("Frame", {
		Size = UDim2.new(1, 0, 1, -28),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundTransparency = 1,
		Parent = mareColumn,
	})
	gui.MareList = scrollList(mareListArea, "MareList")

	local breedingBottom = create("Frame", {
		Size = UDim2.new(1, 0, 0, 82),
		Position = UDim2.new(0, 0, 1, -82),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = pages.Breeding,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = breedingBottom })
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		Parent = breedingBottom,
	})

	gui.BreedingSelectionLabel = create("TextLabel", {
		Size = UDim2.new(1, -160, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "父: 未選択 / 母: 未選択",
		TextColor3 = Theme.SubText,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = breedingBottom,
	})
	gui.BreedingResultLabel = create("TextLabel", {
		Size = UDim2.new(1, -160, 0, 24),
		Position = UDim2.new(0, 0, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = Theme.Accent,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = breedingBottom,
	})
	gui.BreedButton = create("TextButton", {
		Name = "BreedButton",
		Size = UDim2.new(0, 140, 0, 44),
		Position = UDim2.new(1, -140, 0.5, -22),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "配合する",
		TextColor3 = Color3.fromRGB(30, 24, 10),
		TextSize = 16,
		Parent = breedingBottom,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = gui.BreedButton })

	-- Race page: horse selector (left) + queue/track (right)
	local raceLeft = create("Frame", {
		Size = UDim2.new(0, 360, 1, 0),
		BackgroundTransparency = 1,
		Parent = pages.Race,
	})
	gui.RaceHorseList = scrollList(raceLeft, "RaceHorseList")

	local raceRight = create("Frame", {
		Size = UDim2.new(1, -376, 1, 0),
		Position = UDim2.new(0, 376, 0, 0),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Parent = pages.Race,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = raceRight })
	create("UIPadding", {
		PaddingTop = UDim.new(0, 16),
		PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
		Parent = raceRight,
	})

	local raceButtonsRow = create("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Parent = raceRight,
	})
	gui.RaceJoinButton = create("TextButton", {
		Name = "RaceJoinButton",
		Size = UDim2.new(0, 160, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "レースに参加",
		TextColor3 = Color3.fromRGB(30, 24, 10),
		TextSize = 15,
		Parent = raceButtonsRow,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = gui.RaceJoinButton })
	gui.RaceLeaveButton = create("TextButton", {
		Name = "RaceLeaveButton",
		Size = UDim2.new(0, 120, 1, 0),
		Position = UDim2.new(0, 170, 0, 0),
		BackgroundColor3 = Theme.PanelLight,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Text = "キャンセル",
		TextColor3 = Theme.SubText,
		TextSize = 15,
		Parent = raceButtonsRow,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = gui.RaceLeaveButton })

	gui.RaceStatusLabel = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 0, 48),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "出走する馬を選択してください",
		TextColor3 = Theme.SubText,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = raceRight,
	})

	gui.RaceTrack = create("Frame", {
		Name = "RaceTrack",
		Size = UDim2.new(1, 0, 0, 260),
		Position = UDim2.new(0, 0, 0, 80),
		BackgroundTransparency = 1,
		Parent = raceRight,
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = gui.RaceTrack,
	})

	gui.RaceResultLabel = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, -350),
		Position = UDim2.new(0, 0, 0, 350),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = raceRight,
	})

	setActiveTab("Stable")

	return gui
end

return UIBuilder
