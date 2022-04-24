local module = {}

local DataStoreService = game:GetService("DataStoreService")

local ColdPlayerMemory = DataStoreService:GetDataStore("__VAULT__DATASTORE")

function module:GetAsync(player)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ColdPlayerMemory:GetAsync(player.UserId)
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
		getData = ColdPlayerMemory:SetAsync(player.UserId,value)
	end)
	if getSuccess then
		return getData
	else
		return getError, not getSuccess
	end
end

return module