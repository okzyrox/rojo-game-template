--// Utils
--// cc: okzyrox

--/ Services
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")


--- @class GeneralUtils
--- A module containing general utility functions that can be used to standardise doing things across the project.
local Utils = {}

export type TypeInfo = {
	ExpectedType: string,
	Value: any
}

export type TypeMap = {
	--/ var name : typeinfo
	[string]: TypeInfo
}

local randomChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local expandedRandomChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"

function Utils:AssertTypes(typeMap: TypeMap): boolean
	local result = true
	
	for varName: string, typeInfo: TypeInfo in typeMap do
		local valueType = typeof(typeInfo.Value)
		if valueType == typeInfo.ExpectedType then
			if result == false then
				continue
			end
			--/ Passed
		else
			result = false
			warn(`! Typecheck failed for {varName}; got {valueType}, expected {typeInfo.ExpectedType}`)
		end
	end
	
	return result
end

--- Get or create a folder with a given name, either in the workspace or under a given parent instance.
--- **Yields** on the Client.
--- @param name -- The name of the folder to get or create.
--- @param parent -- The parent instance to look for the folder under. Defaults to workspace.
--- @param client -- Whether or not to yield on the client. Will create the folder on the client if true.
--- @return Folder? -- The resulting folder instance.
--- @yields
function Utils:UseFolder(name: string, parent: Instance?, client: boolean?): Folder
	if RunService:IsServer() or client == true then
		if parent and parent:WaitForChild(name, 2) then
			return parent:FindFirstChild(name) :: Folder
		elseif workspace:WaitForChild(name, 2) then
			return workspace:FindFirstChild(name) :: Folder
		else
			local folder = Instance.new("Folder")
			folder.Name = name
			folder.Parent = parent or workspace
			return folder
		end
	else
		if parent then
			return parent:WaitForChild(name) :: Folder
		else
			return workspace:WaitForChild(name) :: Folder
		end
	end
end

--- Recursively runs UseFolder on a path, and returns them seperately.
--- **Yields** on the Client.
--- @param path -- The path of the folders to get or create, seperated by "/".
--- @param parent -- The parent instance to look for the folders under. Defaults to workspace.
--- @param client -- Whether or not to yield on the client. Will create the folders on the client if true.
--- @return ...Folder -- The resulting folder instances, in order of the path.
--- @yields
function Utils:UseFoldersByPath(path: string, parent: Instance?, client: boolean?): ...Folder
	local folders = {}
	local currentParent = parent or workspace
	for folderName in path:gmatch("[^/]+") do
		local folder = self:UseFolder(folderName, currentParent, client)
		table.insert(folders, folder)
		currentParent = folder
	end
	return table.unpack(folders)
end

--- Generate a random ID string of a given length. By default, is of 15 characters and consists of uppercase letters and numbers, but can be expanded to include lowercase and special characters.
--- @param len -- The length of the generated string. Optional, defaults to 15.
--- @param expandedCharSet -- Whether or not to use the expanded character set, which includes lowercase letters and special characters. (Optional, defaults to false.)
--- @return string -- The generated random ID.
--- @within GeneralUtils
function Utils:GenerateRandomId(len: number?, expandedCharSet: boolean?): string
	local charset = expandedCharSet and expandedRandomChars or randomChars
	local stringLen = len or 15

	math.randomseed(os.clock() * 1000)

	local result = ""

	for _i = 1, stringLen do
		local randIndex = math.random(1, #charset)
		result = result .. charset:sub(randIndex, randIndex)
	end

	return result
end

--- Generate a random Color3 value.
--- @return Color3 -- The generated random Color3.
--- @within GeneralUtils
function Utils:GenerateRandomColor3(): Color3
	math.randomseed(os.clock() * 1000)

	return Color3.fromRGB(
		math.random(0, 255),
		math.random(0, 255),
		math.random(0, 255)
	)
end

--- Format a timestamp into human-readable format. The output is "YYYY-MM-DD HH:MM".
--- @param timestamp -- The timestamp to format, in seconds since the Unix epoch.
--- @return string -- The formatted timestamp.
--- @within GeneralUtils
function Utils:FormatTimestamp(timestamp: number): string
	local date = os.date("*t", timestamp)
	return string.format("%04d-%02d-%02d %02d:%02d", date.year, date.month, date.day, date.hour, date.min)
end

--- Convert a Color3 value to a string in the format of `{R},{G},{B}`, where R,G and B are the red, green and blue components of the color respectively, in the range of 0-255.
--- @param color -- The Color3 value to convert.
--- @return string -- The resulting string in the format of `{R},{G},{B}`
--- @within GeneralUtils
function Utils:ToStringColor3(color: Color3): string
	local r = math.floor(color.R * 255)
	local g = math.floor(color.G * 255)
	local b = math.floor(color.B * 255)
	return `{r},{g},{b}`
end

--- Convert a string in the format of `{R},{G},{B}` to a Color3 value, where R,G and B are the red, green and blue components of the color respectively, in the range of 0-255.
--- @param colorStr -- The string to convert, in the format of `{R},{G},{B}`
--- @return Color3 -- The resulting Color3 value.
--- @within GeneralUtils
function Utils:FromStringColor3(colorStr: string): Color3
	local parts = colorStr:split(",")
	local rPart = tonumber(parts[1])
	local gPart = tonumber(parts[2])
	local bPart = tonumber(parts[3])

	return Color3.fromRGB(rPart, gPart, bPart)
end

function Utils:StringStartsWith(str: string, start: string): boolean
	return str:sub(1, #start) == start
end

function Utils:RoundPlaces(num: number, places: number): number
	local mult = 10 ^ places
	return math.floor(num * mult + 0.5) / mult
end

function Utils:GetSoundFromGroup(group: string, name: string, soundId: string?): Sound?
	local groupFolder = SoundService:FindFirstChild(group) :: Folder?
	if not groupFolder then
		return nil
	end

	local soundObject = groupFolder:FindFirstChild(name) :: Sound?
	if not soundObject and not soundId then
		return nil
	end

	if not soundObject and soundId then
		for _, sound in groupFolder:GetChildren() do
			if sound:IsA("Sound") and sound.SoundId == soundId then
				soundObject = sound
				break
			end
		end
	end

	return soundObject
end

function Utils:Sound(
	name: string, 
	group: string?, 
	id: number | string, 
	volume: number?, 
	speed: number?, 
	pitchShift: {Octave: number, Priority: number}?,
	reverb: {DecayTime: number?, Density: number?, Diffusion: number?, DryLevel: number, WetLevel: number, Priority: number}?
): Sound
	if not group then
		group = "General"
	end
	
	if not volume then
		volume = 0.5
	end

	if not speed then
		speed = 1
	end

	local soundId: string
	if Utils:StringStartsWith(tostring(id), "rbxassetid://") then
		soundId = tostring(id)
	else
		soundId = "rbxassetid://" .. tostring(id)
	end

	local existingSound = Utils:GetSoundFromGroup(group :: string, name, soundId)
	if existingSound then
		return existingSound
	end

	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = soundId
	sound.Volume = volume
	sound.PlaybackSpeed = speed
	
	local groupFolder = SoundService:FindFirstChild(group) :: Folder?
	if not groupFolder then 
		groupFolder = Instance.new("Folder")
		groupFolder.Name = group
		groupFolder.Parent = SoundService
	end

	sound.Parent = groupFolder
	if pitchShift then
		local pitchModifier = Instance.new("PitchShiftSoundEffect")
		pitchModifier.Enabled = true
		pitchModifier.Octave = pitchShift.Octave
		pitchModifier.Priority = pitchShift.Priority
		pitchModifier.Parent = sound
	end

	if reverb then
		local reverbModifier = Instance.new("ReverbSoundEffect")
		reverbModifier.Enabled = true
		reverbModifier.DecayTime = reverb.DecayTime or 1
		reverbModifier.Density = reverb.Density or 1
		reverbModifier.Diffusion = reverb.Diffusion or 1
		if reverb.DryLevel then
			reverbModifier.DryLevel = reverb.DryLevel
		end
		if reverb.WetLevel then
			reverbModifier.WetLevel = reverb.WetLevel
		end
		if reverb.Priority then
			reverbModifier.Priority = reverb.Priority
		end
		reverbModifier.Parent = sound
	end

	return sound
end


--- Attempts to find a Character's Humanoid from the given Instance
--- @param instance -- The Instance to start searching from.
--- @return Humanoid? -- The Humanoid found, or nil if not found.
function Utils:FindHumanoid(instance: Instance): Humanoid?
	if not instance then
		return nil
	end


	local Model = instance:FindFirstAncestorWhichIsA("Model")
	if Model then
		local Humanoid = Model:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Humanoid
		end
	elseif instance:IsA("Model") then
		local Humanoid = instance:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Humanoid
		end
	end

	return nil
end

return Utils