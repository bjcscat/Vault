local module = {}

local DataStoreService = require("DataStoreService")

local ColdPlayerMemory = DataStoreService:GetDataStore("__VAULT__DATASTORE")

function module:GetAsync(this,player)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ColdPlayerMemory:GetAsync(player.UserId)
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
		getData = ColdPlayerMemory:SetAsync(player.UserId,value)
	end)
	if getSuccess then
		return getData
	else
		return getError, getSuccess
	end
end

return module