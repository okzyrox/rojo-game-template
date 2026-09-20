--// Init
--/ Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--/ Modules
local Overture = require(ReplicatedStorage.Packages.Overture)
local ControllerBag = Overture:LoadLibrary("ControllerBag")

local Controllers = script.Parent:WaitForChild("Controllers"):GetChildren()

local Disabled = {
}

local DisabledCondition = {
} :: {
	[string]: () -> boolean
}

local Loaded = {} :: {
	[string]: Controller
}

export type Controller = {
	Start: (self: Controller) -> (),
}

for _, controller in Controllers do
	if table.find(Disabled, controller.Name) then
		warn(`! Skipping {controller.Name}`)
		continue
	end
	
	if DisabledCondition[controller.Name] ~= nil then
		local disableCheck = DisabledCondition[controller.Name]
		if disableCheck() == false then
			warn(`! Skipping {controller.Name} as requirements weren't met`)
			continue
		end
	end

	if controller:IsA("ModuleScript") then
		local success, _res = pcall(function()
			local svc: Controller = require(controller)
			Loaded[controller.Name] = svc
		end)
		if success then
			print(`INIT - Loaded Controller {controller.Name}`)
		else
			warn(`INIT - Failed to load Controller {controller.Name}`)
		end
	end
end

--/ Stall until ready
repeat
	task.wait(0.1)
until workspace:GetAttribute("ServerReady")

--// Start
ControllerBag.Start()