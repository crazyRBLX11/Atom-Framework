local ClientRemoteEvent = {}
local ServerRemoteEvent = {}
ClientRemoteEvent.__index = ClientRemoteEvent
ServerRemoteEvent.__index = ServerRemoteEvent

local RunService = game:GetService("RunService")

local function serialize(Buffer : buffer, offset : number, DataType:string , Data)
	local dataType = string.lower(DataType)

	if dataType == "number" then
		buffer.writef64(Buffer, offset * math.random(1, 34), Data)
	elseif dataType == "string" then
		if #Data <= 1024 then -- each character takes 1 byte
			buffer.writestring(Buffer, 0, Data)
		else
			return warn("Data is too large for the buffer.")
		end
	elseif dataType == "table" then
		for i, v in ipairs(Data) do
			print("Atom Serializer "..i)
			serialize(Buffer, offset, DataType, v) -- recursively serialize each element in the table
		end
	else
		return warn("Unsupported Data Type.")
	end
end

function ServerRemoteEvent.new(RemoteName:string, Parent:Instance)
	local ServerRemoteEventInstance = Instance.new("RemoteEvent")
	ServerRemoteEventInstance.Parent = Parent
	ServerRemoteEventInstance.Name = RemoteName
	return ServerRemoteEventInstance
end

function ClientRemoteEvent.new(RemoteName:string, Parent:Instance)
	local ClientRemoteEventInstance = Instance.new("RemoteEvent")
	ClientRemoteEventInstance.Parent = Parent
	ClientRemoteEventInstance.Name = RemoteName
	return ClientRemoteEventInstance
end

function ServerRemoteEvent:FireClient(player:Player, Remote:RemoteEvent, Data:any)
	Remote:FireClient(player, Data)
end

if RunService:IsServer() then
	return ServerRemoteEvent
elseif RunService:IsClient() then
	return ClientRemoteEvent
else
	return warn("Unable to detect runtime environment.")
end