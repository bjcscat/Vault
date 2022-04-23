local module = {
	DataToPlayer={},
	PlayerToData={},
}

local DataStore = require(script.Parent.DataStore)
local MemoryStore = require(script.Parent.MemoryStore)

local masterTemplate = {
	outstandingTransaction = false,
	unresolvedSession = false,
	userData = {}
}

function crosscheck(template,response)
	for index, placeholder in pairs(template) do
		response[index] = response[index] or placeholder
	end
end

function loadMSS(player)
	local data, failure = MemoryStore:GetAsync(player)
	if failure then
		warn("MemoryStore attempted load failed:",data)
		return false
	end
	return data
end

function loadDSS(player)
	local data, failure = DataStore:GetAsync(player)
	if failure then
		warn("DataStore attempted load failed:",data)
		return false
	end
	return data
end

function immediateMSS(player,data)
	local data, failure = MemoryStore:SetAsync(player,data)
	return not failure
end

function dualWrite(Player, DataHolder)
	local memoryStoreResp, memoryStoreFailure = MemoryStore:SetAsync(Player, DataHolder)
	local dataStoreResp, dataStoreFailure = DataStore:SetAsync(Player, DataHolder)
	if dataStoreFailure then
		warn("DataStore attempted load failed:",dataStoreFailure)
		return false
	end
	if memoryStoreFailure then
		warn("MemoryStore attempted load failed:",memoryStoreFailure)
		return false
	end
	return dataStoreResp and memoryStoreResp
end

function module:LoadTemplate(self,template)
	self.template = template
end

function module:LoadPlayer(self,player)
	if not self.template then
		warn("Template not set. Continuing with no template checks.")
	end

	local Player = loadMSS(player) or loadDSS(player) or {}
	local PlayerInterface = newproxy(1)

	crosscheck(masterTemplate,Player)
	crosscheck(self.template,Player.userData)

	Player.unresolvedSession = game.JobId

	immediateMSS(player,Player)

	setmetatable(PlayerInterface,{
		__index = Player.userData,
		__newindex = Player.userData,
	})

	function PlayerInterface:BeginTransaction()
		Player.outstandingTransaction = true
		return immediateMSS(Player)
	end

	function PlayerInterface:EndTransaction()
		local success = immediateMSS(Player)
		if success then
			Player.outstandingTransaction = false
			dualWrite(player,Player)
		end
		return success
	end
	
	module.PlayerToData[player] = Player
	module.DataToPlayer[Player] = player

	return Player
end

game.Players.PlayerRemoving:Connect(function(player)
	local playerData = module.PlayerToData[player]
	if playerData then

		if playerData.outstandingTransaction == false then
			playerData.unresolvedSession = game.JobId
			dualWrite(player,playerData)
		end

		module.DataToPlayer[playerData] = nil
		module.PlayerToData[player] = nil
	end
end)

game:BindToClose(function()
	task.wait(5)
	for Data,Player in pairs(module.DataToPlayer) do

		if Data.outstandingTransaction == false then
			Data.unresolvedSession = game.JobId
			task.spawn(dualWrite,Player,Data)
		end

		module.DataToPlayer[Data] = nil
		module.PlayerToData[Player] = nil
	end
end)

task.spawn(function()
	while task.wait(60) do
		for Data,Player in pairs(module.DataToPlayer) do
			if Player.outstandingTransaction == false then
				dualWrite(Player,Data)
			end
		end
	end
end)