local module = {}

local MemoryStoreService = game:GetService("MemoryStoreService")

local ActivePlayerMemory = MemoryStoreService:GetSortedMap("__VAULT__MEMORYSTORE")

local MAXTIME = 3888000

function module:GetAsync(player)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ActivePlayerMemory:GetAsync(player.UserId)
	end)
	if getSuccess then
		return getData
	else
		return getError, not getSuccess
	end
end

function module:SetAsync(player,value)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ActivePlayerMemory:SetAsync(player.UserId,value,MAXTIME)
	end)
	if getSuccess then
		return getData
	else
		return getError, not getSuccess
	end
end

return module