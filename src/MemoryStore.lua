local module = {}

local MemoryStoreService = game:GetService("MemoryStoreService")

local ActivePlayerMemory = MemoryStoreService:GetSortedMap("__VAULT__MEMORYSTORE")

local MAXTIME = 86000

function module:GetAsync(player: Player): (any, boolean)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ActivePlayerMemory:GetAsync(player.UserId)
	end)
	if getSuccess then
		return getData, false
	else
		return getError, not getSuccess
	end
end

function module:SetAsync(player: Player,dataholder): (boolean)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ActivePlayerMemory:SetAsync(player.UserId,dataholder,MAXTIME)
	end)
	return getSuccess
end

return module
