local Switch, case, default = unpack(require(script.Switch))

local Serializer = {}

function Serializer.serialize(Buffer: buffer, offset: number, DataType: string, Data)
	local dataType = string.lower(DataType)
	print(dataType)
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
				print("Atom Serializer "..i)
				Serializer.serialize(Buffer, offset, DataType, v) -- recursively serialize each element in the table
			end
		end),

		default()(function()
			return warn("Unsupported Data Type.")
		end),
	})
end

function Serializer.deserialize(Buffer, offset, DataType)
	local dataType = string.lower(DataType)

	if dataType == "number" then
		-- Assuming buffer.readf64 reads a 64-bit float
		local data = buffer.readf64(Buffer, offset)
		return data
	elseif dataType == "string" then
		-- Assuming buffer.readstring reads a string from the buffer
		local data = buffer.readstring(Buffer, offset, 0)
		return data
	--[[elseif dataType == "table" then
		local result = {}
		-- Assuming you know the table structure (e.g., fixed size or dynamic)
		-- You'll need to adapt this part based on your specific use case
		for i = 1, numElements do
			local element = deserialize(Buffer, offset, DataType)
			table.insert(result, element)
		end
		return result ]]
	else
		print("Unsupported Data Type.")
	end
end

return Serializer
