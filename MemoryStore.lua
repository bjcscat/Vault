local module = {}

local MemoryStoreService = require("MemoryStoreService")

local ActivePlayerMemory = MemoryStoreService:GetSortedMap("__VAULT__MEMORYSTORE")

local MAXTIME = 3888000

function module:GetAsync(this,player)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ActivePlayerMemory:GetAsync(player.UserId)
	end)
	if getSuccess then
		return getData
	else
		return getError, getSuccess
	end
end

function module:SetAsync(this,player,value)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ActivePlayerMemory:SetAsync(player.UserId,value,MAXTIME)
	end)
	if getSuccess then
		return getData
	else
		return getError, getSuccess
	end
end

return module