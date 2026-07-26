local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesSetup = {}

local REMOTE_DEFINITIONS = {
	{ Name = "GetStableData", Type = "RemoteFunction" },
	{ Name = "TrainHorse", Type = "RemoteFunction" },
	{ Name = "BreedHorses", Type = "RemoteFunction" },
	{ Name = "JoinRaceQueue", Type = "RemoteFunction" },
	{ Name = "LeaveRaceQueue", Type = "RemoteFunction" },
	{ Name = "RetireHorse", Type = "RemoteFunction" },
	{ Name = "RaceResult", Type = "RemoteEvent" },
}

function RemotesSetup.Init()
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end

	local remotes = {}
	for _, definition in ipairs(REMOTE_DEFINITIONS) do
		local instance = folder:FindFirstChild(definition.Name)
		if not instance then
			instance = Instance.new(definition.Type)
			instance.Name = definition.Name
			instance.Parent = folder
		end
		remotes[definition.Name] = instance
	end

	return remotes
end

return RemotesSetup
