local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Modules.Constants)
local Theme = require(script.Parent.Theme)

local create = Theme.Create

local HorseCard = {}

local function statRow(parent, layoutOrder, statName, value)
	local row = create("Frame", {
		Name = statName .. "Row",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Parent = parent,
	})

	create("TextLabel", {
		Size = UDim2.new(0, 55, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = statName,
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local barBg = create("Frame", {
		Size = UDim2.new(1, -95, 0, 10),
		Position = UDim2.new(0, 55, 0.5, -5),
		BackgroundColor3 = Theme.PanelLight,
		BorderSizePixel = 0,
		Parent = row,
	})
	create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barBg })

	local fillScale = math.clamp(value / Constants.StatCap, 0, 1)
	local bar = create("Frame", {
		Size = UDim2.new(fillScale, 0, 1, 0),
		BackgroundColor3 = Theme.StatColors[statName],
		BorderSizePixel = 0,
		Parent = barBg,
	})
	create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })

	create("TextLabel", {
		Size = UDim2.new(0, 40, 1, 0),
		Position = UDim2.new(1, -40, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = tostring(value),
		TextColor3 = Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})

	return row
end

-- options: { ShowSelect = bool, SelectText = string, ShowRetire = bool }
function HorseCard.Create(horse, options)
	options = options or {}

	local card = create("Frame", {
		Name = "HorseCard_" .. horse.Id,
		Size = UDim2.new(1, -8, 0, 224),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
	create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = card,
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = card,
	})

	-- Header: name + record
	local header = create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = card,
	})

	local genderIcon = horse.Gender == "Stallion" and "♂" or "♀"
	local retiredTag = horse.Retired and " [引退]" or ""
	create("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = ("%s %s (世代%d)%s"):format(genderIcon, horse.Name, horse.Generation, retiredTag),
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	create("TextLabel", {
		Size = UDim2.new(0, 70, 1, 0),
		Position = UDim2.new(1, -70, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = ("%d戦%d勝"):format(horse.Races, horse.Wins),
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header,
	})

	-- Stats
	local statsFrame = create("Frame", {
		Name = "Stats",
		Size = UDim2.new(1, 0, 0, 5 * 18 + 4 * 3),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = card,
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
		Parent = statsFrame,
	})
	for i, statName in ipairs(Constants.StatNames) do
		statRow(statsFrame, i, statName, horse.Stats[statName])
	end

	-- Energy + Condition
	local statusRow = create("Frame", {
		Name = "Status",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = card,
	})
	create("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = ("⚡ %d/%d"):format(horse.Energy, Constants.MaxEnergy),
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = statusRow,
	})
	create("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "調子: " .. horse.Condition,
		TextColor3 = Theme.ConditionColor[horse.Condition] or Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = statusRow,
	})

	-- Buttons
	local buttonsRow = create("Frame", {
		Name = "Buttons",
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = 4,
		Parent = card,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = buttonsRow,
	})

	if options.ShowSelect and not horse.Retired then
		local selectButton = create("TextButton", {
			Name = "SelectButton",
			Size = UDim2.new(0, 110, 1, 0),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = options.SelectText or "選択",
			TextColor3 = Color3.fromRGB(30, 24, 10),
			TextSize = 13,
			LayoutOrder = 1,
			Parent = buttonsRow,
		})
		create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = selectButton })
	end

	if options.ShowRetire and not horse.Retired then
		local retireButton = create("TextButton", {
			Name = "RetireButton",
			Size = UDim2.new(0, 90, 1, 0),
			BackgroundColor3 = Theme.PanelLight,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "引退させる",
			TextColor3 = Theme.SubText,
			TextSize = 13,
			LayoutOrder = 2,
			Parent = buttonsRow,
		})
		create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = retireButton })
	end

	return card
end

return HorseCard
