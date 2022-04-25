local utils = {}

function utils.deepcopy(table)
	local copy = {}

	for key, value in pairs(table) do
		if typeof(value) == "table" then
			value = utils.deepcopy(value)
		end

		if typeof(key) == "number" then
			table.insert(copy, key, value)
		else
			copy[key] = value
		end
	end

	return copy
end

function utils.crosscheck(template,response,overwrite)
	for index, placeholder in pairs(template) do
		if not response[index] and not overwrite then
			if type(placeholder) == "table" then
				response[index] = {}
				utils.crosscheck(placeholder,response[index])
			end
			response[index] = response[index] or placeholder
		elseif overwrite then
			if type(placeholder) == "table" then
				response[index] = {}
				utils.crosscheck(placeholder,response[index])
			end
			response[index] = placeholder
		end
	end
	return response
end

return utils