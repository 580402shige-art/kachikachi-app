local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

local UIBuilder = require(script.Parent.UI.UIBuilder)
local StableController = require(script.Parent.Controllers.StableController)
local TrainingController = require(script.Parent.Controllers.TrainingController)
local BreedingController = require(script.Parent.Controllers.BreedingController)
local RaceController = require(script.Parent.Controllers.RaceController)

local gui = UIBuilder.Build()

StableController.Init(gui, remotesFolder)
TrainingController.Init(gui, remotesFolder, StableController)
BreedingController.Init(gui, remotesFolder, StableController)
RaceController.Init(gui, remotesFolder, StableController)

StableController.Refresh()
