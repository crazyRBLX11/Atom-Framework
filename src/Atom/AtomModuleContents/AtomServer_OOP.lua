--!native
--!strict
--[[     

Rewrite of my 2019-2021 framework.
~31/10/2023 crazyattaker1

V0.1
Started Development.

V0.2
Moved some of the code in the main script into modular code for readability.
Added SubTicks.
Temporarily removed my ModuleLoader as it broke intellisense.
Added the serializer.

V0.4
Implemented the AtomMain.GetService() function,
Implemented the AtomMain.CreateRemoteEvent() function,
Implemented the AtomMain.CreateUnreliableEvent() function,
Implented the Atom.GetSignal() function,

V0.5
Moved the serializer to a seperate script for modularity and added a copy of it's requirements to it.
Fixed the cylical dependency bug in the Module Loader.

Tools Used in Atom Development: VSCode Insider Edition, Argon Code Sync.

]]

-- Initialize the Module Script table to allow external access
-- to the API and making a reference to where everything SHOULD be stored.
local AtomMain = {}
local AtomRoot = script.Parent.Parent
AtomRoot.Parent = game:GetService("ReplicatedStorage")

local started: boolean = false
local startComplete: boolean = false

-- Set Important Directories
local Services = AtomRoot.Services -- Needed for custom require and it will be needed further in the script.
local Controllers = AtomRoot.Controllers
local Components = AtomRoot.Components
local Packages = AtomRoot:WaitForChild("Packages")

local Utility = Packages.Utility

-- Overwrite Functions
local ModuleLoader = require(script.Parent.Utils.ModuleLoader) -- Needed for custom require.
--[[local function require(Directory:Instance, ScriptName:string)
	return ModuleLoader:require(Directory, ScriptName)
end ]]

function SubTick()
	return tick() / 2
end

--[[ Currently unused as it broke intellisense. [[
local BSON = require(Packages, "BSON")
local ByteNet = require(Packages, "ByteNet")
local GoodSignal = require(Packages, "GoodSignal")
local Janitor = require(Packages, "Janitor")
local Promise = require(Packages, "Promise")
local Proto = require(Packages, "proto")
local ProfileService = require(Packages, "ProfileService")
local Sourceesque = require(Packages, "Sourceesque")
local Warp = require(Packages, "Warp")
local RestrictRead = require(Utility, "restrictRead")
local Switch, case, default = unpack(require(Packages, "Switch")) ]]

local BSON = require(Packages.BSON)
local ByteNet = require(Packages.ByteNet)
local GoodSignal = require(Packages.GoodSignal)
local Janitor = require(Packages.Janitor)
local Promise = require(Packages.Promise)
local Proto = require(Packages.proto)
local ProfileService = require(Packages.ProfileService)
local Sourceesque = require(Packages.Sourceesque)
local Warp = require(Packages.Warp)
local Switch, case, default = unpack(require(Packages.Switch))

-- Make references for Repositories.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Remotes = AtomRoot.AtomRemotes

local onCompletedSignal = Instance.new("BindableEvent", Remotes.BindableEvents)
onCompletedSignal.Name = "onCompleted"
local ErrorSignal = GoodSignal.new()

-- DRY Signal Handler.
ErrorSignal:Connect(function(message)
	error(message, 2)
end)

--[[
Internal clean function.

Run the function Clean()

This function can be used anywhere internally and should 
be used like the following:
function YourFunction(YourFunctionsParmaters)
	local YourFunctionsJanitor = Janitor.new()
	-- Your Function's Code
	YourFunctionsJanitor:Add(YourFunctionsInstance)
	Clean(YourFunctionsJanitor)
end

]]

function Clean(WorkingJanitor)
	WorkingJanitor:Cleanup()
	return "Cleaned."
end

--[[
Start the framework.

Require the ModuleScript and run this function ONCE
to set up the framework for everything else.

This function is located in the customizable BootStrapper
parented under this ModuleScript and should be used like 
the following:
local Atom = require(script.Parent)
Atom.Start()

]]
function AtomMain.Start()
	if started then return Promise.reject("Atom has already started.") end
	if _VERSION ~= "Luau" then ErrorSignal:Fire("Running on an External Lua Runtime.") return end

	local StartTick = tick()
	local StartSubTick = SubTick()

	started = true

	return Promise.new(function(resolve)
		-- Create a Janitor to clean unneeded files post setup.
		local InitJanitor = Janitor.new()

		Remotes.Parent = ReplicatedStorage
		Services.Parent = ServerStorage
		Controllers.Parent = ReplicatedStorage
		Components.Parent = ReplicatedStorage

		-- Auto Installer.
		-- Reads through the Atom Root Directory to find files before checking the
		-- Cleanable attribute. If the attribute is true the file will be cleaned and if it's
		-- false then it will be left alone.

		local MaxFolderItterations = 4
		local CurrentFolderItterations = 0
		for i, v in ipairs(AtomRoot:GetChildren()) do
			if CurrentFolderItterations >= MaxFolderItterations then
				break
			end

			if CurrentFolderItterations < MaxFolderItterations then
				CurrentFolderItterations = CurrentFolderItterations + 1
				print("Currently on the " .. CurrentFolderItterations .. " itteration.")
				if v:IsA("Folder") then -- If it's a Folder, continue.
					if v:GetAttribute("Cleanable") ~= false then
						-- Reads through the directory to find any files to be moved before
						-- preparing it to be cleaned.
						for _, scriptObject in pairs(v:GetChildren()) do
							InitJanitor:Add(v)
						end
					end
				end
			end
		end

		local servicesInitPromises = {}

		for _, service in ipairs(Services:GetDescendants()) do
			if service:IsA("ModuleScript") and service.Name:match("Service$") then
				table.insert(
					servicesInitPromises,
					Promise.new(function(r)
						debug.setmemorycategory(service.Name)
						local servicetouse = require(Services:WaitForChild(service.Name))
						local serviceClass = servicetouse.new()
						serviceClass:Init()
						task.wait()
						serviceClass:Start()
						r()
					end)
				)
			end
		end

		-- Cleaning up anything left from the Auto Installer.
		print(Clean(InitJanitor))
		resolve(Promise.all(servicesInitPromises))
	end):andThen(function()
		--[[local servicesStartPromises = {}

		for _, service in ipairs(Services:GetDescendants()) do
			if service:IsA("ModuleScript") and service.Name:match("Service$") then
				table.insert(
					servicesStartPromises,
					Promise.new(function(r)
						debug.setmemorycategory(service.Name)
						local servicetouse = require(Services:WaitForChild(service.Name))
						local serviceClass = servicetouse.new()
						serviceClass:Start()
						r()
					end)
				)
			end
		end ]]

		startComplete = true
		local EndTick = tick()
		local EndSubTick = SubTick()
		onCompletedSignal:Fire("Atom has started succesfully.")
		local InitTick = tostring(EndTick - StartTick)
		local InitSubTick = tostring(EndSubTick - StartSubTick)
		print("Atom Started with a tick of " .. InitTick .. " and a sub tick of " .. InitSubTick .. ".")
	end)
end

function AtomMain.GetService(ServiceName: string)
	for i, v in ipairs(Services:GetChildren()) do
		if v.ClassName ~= "ModuleScript" and v.Name ~= ServiceName then continue end
		return require(Services:WaitForChild(ServiceName))
	end
end

function AtomMain.CreateRemoteEvent(RemoteName: string)
	local RemoteEvent = Instance.new("RemoteEvent")
	RemoteEvent.Parent = Remotes.RemoteEvents
	RemoteEvent.Name = RemoteName
end

function AtomMain.CreateUnreliableRemoteEvent(RemoteName: string)
	local UnreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
	UnreliableRemoteEvent.Parent = Remotes.UnreliableRemoteEvents
	UnreliableRemoteEvent.Name = RemoteName
end

function AtomMain.GetSignal(SignalName: string, SignalType: string)
	return Remotes:WaitForChild(SignalType.."s"):FindFirstChild(SignalName)
end

local Core = script.Parent.Core

return {
	versiondetails = { major = 0, minor = 5, isrelease = false },
	AtomRoot = AtomRoot,
	Core = AtomRoot.Atom.Core,
	Util = AtomRoot.Atom.Utils,
	Main = AtomMain,
	Badges = require(Core.Badges),
	DataStores = require(Core.DataStore).DataStores,
	MemoryStoreOperations = require(Core.MemoryStoreOperations),
	Serializer = require(Core.Serializer)
}
