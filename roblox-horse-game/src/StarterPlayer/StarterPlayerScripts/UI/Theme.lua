local Theme = {}

Theme.Background = Color3.fromRGB(18, 19, 24)
Theme.Panel = Color3.fromRGB(32, 34, 42)
Theme.PanelLight = Color3.fromRGB(44, 48, 58)
Theme.Accent = Color3.fromRGB(255, 176, 59)
Theme.AccentDim = Color3.fromRGB(180, 125, 45)
Theme.Text = Color3.fromRGB(235, 235, 240)
Theme.SubText = Color3.fromRGB(160, 163, 170)
Theme.Good = Color3.fromRGB(96, 200, 120)
Theme.Normal = Color3.fromRGB(230, 200, 90)
Theme.Bad = Color3.fromRGB(220, 90, 90)

Theme.StatColors = {
	Speed = Color3.fromRGB(255, 99, 99),
	Stamina = Color3.fromRGB(99, 178, 255),
	Power = Color3.fromRGB(255, 176, 59),
	Guts = Color3.fromRGB(200, 99, 255),
	Wisdom = Color3.fromRGB(99, 255, 178),
}

Theme.ConditionColor = {
	Good = Theme.Good,
	Normal = Theme.Normal,
	Bad = Theme.Bad,
}

function Theme.Create(className, props)
	local inst = Instance.new(className)
	for key, value in pairs(props) do
		if key ~= "Parent" then
			inst[key] = value
		end
	end
	if props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

return Theme
