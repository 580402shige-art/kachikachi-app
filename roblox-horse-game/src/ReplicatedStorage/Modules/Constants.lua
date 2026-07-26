local Constants = {}

Constants.StatNames = { "Speed", "Stamina", "Power", "Guts", "Wisdom" }

Constants.StatCap = 1200
Constants.FoundationStatMin = 200
Constants.FoundationStatMax = 500

Constants.MaxEnergy = 100

Constants.RaceDistances = {
	Sprint = 1200,
	Mile = 1600,
	Middle = 2000,
	Long = 2400,
}

Constants.BreedingCooldownSeconds = 30 * 60
Constants.MinRacesBeforeBreeding = 3

return Constants
