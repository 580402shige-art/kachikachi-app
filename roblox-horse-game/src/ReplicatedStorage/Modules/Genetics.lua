local Constants = require(script.Parent.Constants)

local Genetics = {}

local function clamp(x, lo, hi)
	return math.max(lo, math.min(hi, x))
end

-- Child stat = average of both parents, plus mutation noise, plus a small
-- "hybrid vigor" bonus so breeding good horses is worthwhile but never
-- perfectly predictable.
function Genetics.InheritStat(statA, statB)
	local average = (statA + statB) / 2
	local mutationRange = Constants.StatCap * 0.08
	local mutation = (math.random() * 2 - 1) * mutationRange
	local hybridVigor = math.random() * Constants.StatCap * 0.02
	local value = average + mutation + hybridVigor
	return clamp(math.floor(value), 10, Constants.StatCap)
end

function Genetics.Breed(stallion, mare)
	assert(stallion.Gender == "Stallion", "父馬はStallionである必要があります")
	assert(mare.Gender == "Mare", "母馬はMareである必要があります")

	local foalStats = {}
	for _, statName in ipairs(Constants.StatNames) do
		foalStats[statName] = Genetics.InheritStat(stallion.Stats[statName], mare.Stats[statName])
	end

	return {
		Stats = foalStats,
		Generation = math.max(stallion.Generation, mare.Generation) + 1,
		Bloodline = {
			Sire = stallion.Name,
			Dam = mare.Name,
			SireId = stallion.Id,
			DamId = mare.Id,
		},
	}
end

return Genetics
