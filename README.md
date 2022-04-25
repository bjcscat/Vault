# Vault

Low latency, session locked, data access wrapper for Roblox.

Anti-duplication is enhanced even further than with session locking by the implementation of Transactions.

Simple script for giving a coin every minute:
```lua
local Vault = require(game.ReplicatedStorage.Vault.Vault)

Vault:LoadTemplate({
    ["Coins"] = 0
    ["Level"] = 0
})

game.Players.PlayerAdded:Connect(function(player)
    local PlayerWrapper = Vault:LoadPlayer(player) -- Creates a wrapper for accessing data directly
    while task.wait(60) do
        PlayerWrapper.Coins += 1 -- Directly modifies the table without need for methods
    end
end)
```

Hypothetical trading script using transactions:
```lua
function TradePets(player1, player2, pet) -- player1 and player2 are data wrapper instances
    local TradeTransaction = Vault:CreateLinkedTransaction({player1,player2})

    TradeTransaction[player2].Pets[pet] = player1.Pets[pet] --move player1s pet into player 2
    TradeTransaction[player1].Pets[pet] = nil --delete player1s pet

    TradeTransaction:EndTransaction()
end
```
