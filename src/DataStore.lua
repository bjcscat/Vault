local module = {}

local DataStoreService = game:GetService("DataStoreService")

local ColdPlayerMemory = DataStoreService:GetDataStore("__VAULT__DATASTORE")

function module:GetAsync(player: Player): (any,boolean)
	local getData = {}
	local getSuccess, getError = pcall(function()
		getData = ColdPlayerMemory:GetAsync(player.UserId)
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
		getData = ColdPlayerMemory:SetAsync(player.UserId,dataholder)
	end)
	if not getSuccess then
		warn("DataStore save error:",getError)
	end
	return getSuccess
end

return module