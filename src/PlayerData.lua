local PlayerData = {}

local masterTemplate = {
	UnresolvedSession = false,
	UserData = {}
}

local DataStore = require(script.Parent.DataStore)
local MemoryStore = require(script.Parent.MemoryStore)
local Transactions = require(script.Parent.Transactions)

local Utils = require(script.Parent.Utils) :: any

function writeplayer(Player, DataHolder, includemss): boolean

	local memoryStoreResp, memoryStoreFailure = "", false

	if includemss then
		memoryStoreResp, memoryStoreFailure = MemoryStore:SetAsync(Player, DataHolder)
		if memoryStoreFailure then
			warn("MemoryStore attempted save failed:",memoryStoreResp)
			return false
		end
	end

	local dataStoreResp, dataStoreFailure = DataStore:SetAsync(Player, DataHolder)

	if dataStoreFailure then
		warn("DataStore attempted save failed:",dataStoreResp)
		return false
	end

	return dataStoreFailure and memoryStoreFailure
end

function loadMSS(player): (any)
	local data, failure = MemoryStore:GetAsync(player)
	if failure then
		warn("MemoryStore attempted load failed:",data)
		return false
	end
	return data
end

function loadDSS(player): (any)
	local data, failure = DataStore:GetAsync(player)
	if failure then
		warn("DataStore attempted load failed:",data)
		return false
	end
	return data
end

function PlayerData:CreatePlayerData(player: Player, template: {})
	local NewPlayer = Utils.crosscheck(masterTemplate,(loadMSS(player) or loadDSS(player) or {}))
	local PlayerInterface = {}
	
	Utils.crosscheck(template,NewPlayer.UserData)

	NewPlayer.UnresolvedSession = game.JobId
	
	MemoryStore:SetAsync(player, NewPlayer)

	function PlayerInterface:CreateTransaction()
		return Transactions:CreateTransaction(PlayerInterface)
	end

	function PlayerInterface:WriteToMSS(): (boolean)
		return MemoryStore:SetAsync(player, NewPlayer)
	end

	function PlayerInterface:SavePlayer(includemss: boolean): (boolean)
		local memoryStoreResp, memoryStoreFailure = "", false
		if includemss then
			memoryStoreResp, memoryStoreFailure = MemoryStore:SetAsync(player, NewPlayer)
			if memoryStoreFailure then
				warn("MemoryStore attempted save failed:",memoryStoreResp)
				return false
			end
		end 

		local dataStoreResp, dataStoreFailure = DataStore:SetAsync(player, NewPlayer)
		if dataStoreFailure then
			warn("DataStore attempted save failed:",dataStoreResp)
			return false
		end

		return not (dataStoreFailure or memoryStoreFailure)
	end

	function PlayerInterface:Unload()
		NewPlayer.UnresolvedSession = false
		PlayerInterface:SavePlayer(true)
		NewPlayer = nil
		PlayerInterface = nil
	end
	
	return setmetatable(PlayerInterface,{
		__index = function(table,index)
			if index == "UserData" then
				return NewPlayer.UserData
			else
				return NewPlayer.UserData[index]
			end
		end,
		__newindex = function(table,index,value)
			if index == "UserData" then
				NewPlayer.UserData = value 
			else
				NewPlayer.UserData[index] = value
			end
		end,
		__tostring = function()
			return tostring(NewPlayer.UserData)
		end
	})
end

return PlayerData