--// TemplateController
--/ A template controller!

--/ Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--/ Modules
local Overture = require(ReplicatedStorage.Packages.Overture)

local ControllerBag = Overture:LoadLibrary("ControllerBag")

--/ Controller

local TemplateController = ControllerBag.CreateController({
    Name = "TemplateController"
})

function TemplateController:Start()
    print("Hello!")
end

return TemplateController