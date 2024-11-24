--!strict
-- Written by crazyattaker1. 04/04/2024. Loads Atom Modules.
local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

function ModuleLoader:require(Directory, ScriptName: string)
	local Modules = Directory:GetChildren()

	for i, v in ipairs(Modules) do
		if v:IsA("ModuleScript") and v.Name == ScriptName then
			print("Module Loader: " .. i .. ". Requiring " .. v:GetFullName())
			local mod: ModuleScript = require(v)
			return mod
		end
	end

	return nil
end

return ModuleLoader
