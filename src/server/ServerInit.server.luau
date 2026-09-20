--/ Init

local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService:FindFirstChild("Services")
task.wait(1) --/ ts

export type ServiceT = {
	Start: (service: ServiceT) -> (),
}

local Disabled = {
}

local loaded: { [string]: ServiceT } = {}
local loadedCount = 0

for _, service in Services:GetChildren() do
	if table.find(Disabled, service.Name) then
		warn(`! Skipping {service.Name}`)
		continue
	end

	if service:IsA("ModuleScript") then
		local success, res = pcall(function()
			local svc = require(service)
			loaded[service.Name] = svc
		end)
		if success then
			print(`INIT - Loaded Service {service.Name}`)
			loadedCount += 1
		else
			warn(`INIT - Failed to load Service {service.Name}`)
			warn(`Trace: {debug.traceback()} \n Err: {res}`)
		end
	end
end

local started = {}

for serviceName, serviceMod: ServiceT in loaded do
	if not serviceMod.Start then
		continue
	end
	task.spawn(function()
		local success, res = pcall(function()
			serviceMod:Start()
		end)
		if success then
			print(`INIT - Started Service {serviceName}`)
			table.insert(started, serviceName)
            if script:GetAttribute("Debug") == true then
			    print(`{#started}/{loadedCount} done.`)
            end
			if #started == loadedCount then
				print(`INIT - Successfully loaded and started all services!`)
				workspace:SetAttribute("ServerReady", true)
			end
		else
			warn(`INIT - Failed to start Service {serviceName}`)
			warn(`Err: {res}`)
			warn(debug.traceback())
		end
	end)
end