local Transactions = {}

local Utils = require(script.Parent.Utils)

function Transactions:CreateTransaction(Player)
	local Transaction = {
		NewChanges = Utils.deepcopy(Player.UserData),
		Player = Player
	}

	function Transaction:EndTransaction()
		if not Player then Transaction:CancelTransaction() end
		Player.UserData = Utils.crosscheck(Transaction.NewChanges, Player.UserData, true)
		print(Transaction.NewChanges, Player.UserData)
		if Player:WriteToMSS() then
			return Player:SavePlayer(false)
		else
			return false
		end
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

function Transactions:CreateLinkedTransaction(Players: {})
	local TransactionsToLink = {}
	local TransactionMap = {}
	for _,Player in pairs(Players) do
		TransactionsToLink[_] = Transactions:CreateTransaction(Player)
		TransactionMap[Player.Player] = TransactionsToLink[_]
	end
	local LinkedTransaction = {
		Transactions = TransactionsToLink
	}

	function LinkedTransaction:EndTransaction(): (boolean, string)
		local OldData = {}
		for _,Transaction in pairs(TransactionsToLink) do
			OldData[Transaction.Player] = Utils.deepcopy(Transaction.Player.UserData)
			if not Transaction:EndTransaction() then
				LinkedTransaction:CancelTransaction()
				for Player,Data in pairs(OldData) do
					Player.UserData = Data
					Player:WriteToMSS()
				end
				return false, "SAVEERROR"
			end
		end
		return true, ""
	end

	function LinkedTransaction:CancelTransaction()
		for _,Transaction in pairs(LinkedTransaction.Transactions) do
			Transaction:CancelTransaction()
		end
		LinkedTransaction = nil
	end


	setmetatable(LinkedTransaction,{
		__index = function(table,index)
			if typeof(index) == "Instance" and index:IsA("Player") then
				return LinkedTransaction
			end
		end,
		__newindex = function() end
	})

	return LinkedTransaction
end

return Transactions