--!strict
--!native
--[[     
Rewrite of my 2019-2021 framework.
~31/10/2023 crazyattaker1

Tools Used in Atom Development: VSCode Insider Edition, Argon Code Sync.

]]

-- Initialize the Module Script table to allow external access 
-- to the API and making a reference to where everything SHOULD be stored.
local AtomMain = {}
local AtomRoot = script.Parent.Parent

local started = false

-- Make Types for tables and arrays as they don't officially have types.
type tab = { [string] : string | boolean | Instance }
type array<typ> = { [number] : typ }

-- Set Important Directories
local Controllers = AtomRoot.Controllers
local Components = AtomRoot.Components
local Packages = AtomRoot:WaitForChild("Packages")

-- Overwrite Functions
--local ModuleLoader = require(Packages.ModuleLoader) -- Needed for custom require.
--[[local function require(Directory:Instance, ScriptName:string)
	return ModuleLoader.new(Directory, ScriptName)
end ]]

local function SubTick()
	return tick() / 2
end

-- Load all the Packages into Memory.
--[[
local BSON = require(Packages, "BSON")
local GoodSignal = require(Packages, "GoodSignal")
local Janitor = require(Packages, "Janitor")
local PartCache = require(Packages, "PartCache")
local Promise = require(Packages, "Promise")
local Proto = require(Packages, "proto")
local ProfileService = require(Packages, "ProfileService")
local Sourceesque = require(Packages, "Sourceesque")
local Warp = require(Packages, "Warp") ]]

local GoodSignal = require(Packages.GoodSignal)
local Janitor = require(Packages.Janitor)
local Promise = require(Packages.Promise)
local Switch, case, default = unpack(require(Packages.Switch))

function serialize(Buffer: buffer, offset: number, DataType: string, Data)
	local dataType = string.lower(DataType)

	Switch(Data)({
		case("number")(function()
			buffer.writef64(Buffer, offset * math.random(1, 34), Data)
		end),

		case("string")(function()
			if #Data <= 1024 then -- each character takes 1 byte
				buffer.writestring(Buffer, 0, Data)
			else
				return warn("Data is too large for the buffer.")
			end
		end),

		case("table")(function()
			for i, v in ipairs(Data) do
				serialize(Buffer, offset, DataType, v) -- recursively serialize each element in the table
			end
		end),

		default()(function()
			return warn("Unsupported Data Type.")
		end),
	})
end

-- Make references for Repositories.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
end ]]

function Clean(WorkingJanitor)
	WorkingJanitor:Cleanup()
	print("Memory Usage: "..collectgarbage('count').."kb")
	print("Memory Usage: "..collectgarbage('count') * 1024, "B")
	return "Cleaned"
end

--[[
Initialize the framework.

Require the ModuleScript and run this function ONCE
to set up the framework for everything else.

This function is located in the customizable BootStrapper
parented under this ModuleScript and should be used like 
the following:
local Origin = require(script.Parent)
Origin:Init()

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

		local controllerInitPromises = {}

		for _, Controller in ipairs(Controllers:GetDescendants()) do
			if Controller:IsA("ModuleScript") and Controller.Name:match("Controller$") then
				table.insert(
					controllerInitPromises,
					Promise.new(function(r)
						debug.setmemorycategory(Controller.Name)
						local controllertouse = require(Controllers)
						controllertouse.new()
						controllertouse:Init()
						r()
					end)
				)
			end
		end

		-- Cleaning up anything left from the Auto Installer.
		print(Clean(InitJanitor))
		resolve(Promise.all(controllerInitPromises))
	end):andThen(function()
		local controllersStartPromises = {}

		for _, controller in ipairs(Controllers:GetDescendants()) do
			if controller:IsA("ModuleScript") and controller.Name:match("Controller$") then
				table.insert(
					controllersStartPromises,
					Promise.new(function(r)
						debug.setmemorycategory(controller.Name)
						local controllertouse = require(Controllers)
						controllertouse.new()
						controllertouse:Start()
						r()
					end)
				)
			end
		end

		started = true
		local EndTick = tick()
		local EndSubTick = SubTick()
		onCompletedSignal:Fire("Atom has started succesfully.")
		local InitTick = tostring(EndTick - StartTick)
		local InitSubTick = tostring(EndSubTick - StartSubTick)		
		print("Atom Started with a tick of "..InitTick.." and a sub tick of "..InitSubTick..".")
	end)
end

--[[function AtomMain.GetController(ControllerName:string)
	for i, v in ipairs(Controllers:GetDescendants()) do
		if v:IsA("ModuleScript") and v.Name == ControllerName then
			return require(Controllers, ControllerName)
		else
			continue
		end
	end
end ]]

local Core = script.Parent.Core

return {
	versiondetails = { major = 0, minor = 6, isrelease = false },
	AtomRoot = AtomRoot,
	Main = AtomMain
}