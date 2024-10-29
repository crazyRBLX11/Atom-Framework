--!native
--!strict
local MemoryStoreOperations = {}

-- Memory Store Service.
-- Functions.
function MemoryStoreOperations:GetMemoryStoreService()
	return game:GetService("MemoryStoreService")
end

function MemoryStoreOperations:CreateMemoryStoreQueue(QueueName:string)
	return game:GetService("MemoryStoreService"):GetQueue(QueueName)
end

function MemoryStoreOperations:GetSortedMap(name:string)
	return game:GetService("MemoryStoreService"):GetSortedMap(name)
end

function MemoryStoreOperations:AddToMemoryStoreQueue(Queue:MemoryStoreQueue, Value:any, Expiration:number, Priority:number)
	Queue:AddAsync(Value, Expiration, Priority)
end

function MemoryStoreOperations:AddToSortedMap(SortedMap:MemoryStoreSortedMap, Key:string, Value:any, Expiration:number)
	SortedMap:SetAsync(Key, Value, Expiration)
end

function MemoryStoreOperations:GetMemoryIdentifier(Queue:MemoryStoreQueue, count:number, allOrNothing:boolean, waitTimeout:number)
	local results, identifier = Queue:ReadAsync(count, allOrNothing, waitTimeout)
	return identifier
end

function MemoryStoreOperations:RemoveFromMemoryStoreQueue(Queue:MemoryStoreQueue, Identifier:string)
	local success, errormessage = pcall(function()
		Queue:RemoveAsync(Identifier)
	end)
	if not success then
		warn("Error removing from MemoryStoreQueue. "..errormessage)
	end
end

function MemoryStoreOperations:ReadFromMemoryStoreQueue(Queue:MemoryStoreQueue, count:number, allOrNothing:boolean, waitTimeout:number)
	local results = nil
	local success, errormessage = pcall(function()
		local results, identifier = Queue:ReadAsync(count, allOrNothing, waitTimeout)
	end)
	if success then
		return results
	elseif not success then
		return "Error reading MemoryStoreQueue. "..errormessage
	else
		return "Error with function. "..errormessage
	end
end

function MemoryStoreOperations:ReadFromSortedMap(SortedMap:MemoryStoreSortedMap, Key:string)
	local success, errormessage = pcall(function()
		SortedMap:GetAsync(Key)
	end)
	if success then
		return SortedMap:GetAsync(Key)
	elseif not success then
		warn("Error getting Value! "..errormessage)
	else
		warn("Error with function! "..errormessage)
	end
end

function MemoryStoreOperations:UpdateSortedMapValue(SortedMap:MemoryStoreSortedMap, Key, transformFunction, Expiration:number)
	SortedMap:UpdateAsync(Key, transformFunction, Expiration)
end

return MemoryStoreOperations