local module = {
	DataToPlayer={},
	PlayerToData={},
	LoadedPlayers={},
}

local DataStore = require(script.Parent.DataStore)
local MemoryStore = require(script.Parent.MemoryStore)

local masterTemplate = {
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
	return not failure,data
end

function writeplayer(Player, DataHolder, includemss)

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

function module:LoadTemplate(template)
	self.template = template
end

function module:LoadPlayer(player)
	if player and module.PlayerToData[player] then return module.LoadedPlayers[player] end
	if not self.template then
		warn("Template not set. Continuing with no template checks.")
	end

	local Player = loadMSS(player) or loadDSS(player) or {}
	local PlayerInterface = {}
	
	crosscheck(masterTemplate,Player)
	crosscheck(self.template,Player.userData)

	Player.unresolvedSession = game.JobId

	immediateMSS(player,Player)
	
	
	function PlayerInterface:CreateTransaction()
		local Transaction = {
			NewChanges = {}
		}

		for index,value in pairs(Player.userData) do
			Transaction.NewChanges[index] = value
		end

		function Transaction:EndTransaction()
			if not player then
				return false, "Player has left game."
			end
			for index,value in pairs(Transaction.NewChanges) do
				Player.userData[index] = value
			end
			local success = immediateMSS(player,Player) 
			if success then
				writeplayer(player,Player,false)
			end
			Transaction = nil
			return success
		end

		function Transaction:CancelTransaction()
			Transaction = nil
		end

		
		setmetatable(Transaction,{
			__index = Transaction.NewChanges,
			__newindex = Transaction.NewChanges
		})
		
		return Transaction
	end
	
	function PlayerInterface:Unload()
		Player = nil
		PlayerInterface = nil
	end

	module.PlayerToData[player] = Player
	module.DataToPlayer[Player] = player
	module.LoadedPlayers[player] = PlayerInterface
	local Interfacemetatable = setmetatable(PlayerInterface,{
		__index = Player.userData,
		__newindex = Player.userData,
		__tostring = function()
			return tostring(Player.userData)
		end
	})
	
	return PlayerInterface
end

game.Players.PlayerRemoving:Connect(function(player)
	local playerData = module.PlayerToData[player]
	if playerData then

		if immediateMSS(player,playerData) then
			playerData.unresolvedSession = false
			writeplayer(player,playerData,true)
		end


	end
end)

game:BindToClose(function()
	for Data,Player in pairs(module.DataToPlayer) do
		task.spawn(function()
			Data.unresolvedSession = false
			local success,err = immediateMSS(Player,Data) 
			print(success,err,Data)
			if success then
				writeplayer(Player,Data,false)
			end
		end)
	end
end)


task.spawn(function()
	while task.wait(60) do
		for Data,Player in pairs(module.DataToPlayer) do
			if not Player then
				module.DataToPlayer[Data] = nil
				module.PlayerToData[Player] = nil
				module.LoadedPlayers[Player]:Unload()
				module.LoadedPlayers[Player] = nil
				continue
			end
			writeplayer(Player,Data,true)
		end
	end
end)

return module