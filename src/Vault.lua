local module = {
	PlayerToData={},
	LoadedPlayers={},
	template={}
}

local PlayerData = require(script.Parent.PlayerData)
local Transactions = require(script.Parent.Transactions)

function module:LoadTemplate(template: {})
	self.template = template
end

function module:LoadPlayer(player)
	if player and module.LoadedPlayers[player] then return module.LoadedPlayers[player] end

	if not self.template then
		warn("Template not set. Continuing with no template checks.")
	end

	local PlayerInterface = PlayerData:CreatePlayerData(player,self.template)

	module.PlayerToData[player] = PlayerInterface
	module.LoadedPlayers[player] = PlayerInterface

	return PlayerInterface
end

function module:CreateLinkedTransaction(Players: {})
	return Transactions:CreateLinkedTransaction(Players)
end

game.Players.PlayerRemoving:Connect(function(player)
	local playerData = module.PlayerToData[player]
	if playerData then
		if playerData:WriteToMSS() then
			module.LoadedPlayers[player]:Unload()
			module.LoadedPlayers[player] = nil
			module.PlayerToData[player] = nil
		end
	end
end)

game:BindToClose(function()
	task.desynchronize()
	for _,Player in pairs(module.LoadedPlayers) do
		if Player:WriteToMSS() then
			Player:Unload()
		end
	end
	task.synchronize()
end)


task.spawn(function()
	while task.wait(60) do
		task.desynchronize()
		for _,Player in pairs(module.LoadedPlayers) do
			Player:SavePlayer(false)
		end
		task.synchronize()
	end
end)

return module