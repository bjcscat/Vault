local Promise = {}
Promise.__index = Promise

function Promise.new(execute)
    local NewPromise = {
        callbacks = {},
        coroutine_function = nil,
        results = {},
        success = nil,
    }

    NewPromise.coroutine_function = coroutine.create(execute)
    
    local tempresults = {coroutine.resume(NewPromise.coroutine_function,function(...)
        NewPromise.success = true
		NewPromise.results = {true,...}
    end, function(...)
        NewPromise.success = false
		NewPromise.results = {false,...}
    end)}
    
	if NewPromise.results == {} then
		NewPromise.results = tempresults
	end
	
    if table.remove(NewPromise.results,1) == false then
        NewPromise.success=false
    end

    for _,callback in pairs(NewPromise.callbacks) do
        if callback[0] == 0 and NewPromise.success then
                    
            callback[1](unpack(NewPromise.results)) -- call with all returned values

        elseif callback[0] == 0 and not NewPromise.success then

            callback[1](unpack(NewPromise.results)) -- call with error

        elseif callback[0] == 2 then

            callback[1](not NewPromise.success, unpack(NewPromise.results)) -- call with success and results

         end
    end
    
    return setmetatable(NewPromise,Promise)
end

function Promise:than(callback)
    if self.success == nil then
        self.callbacks[#self.callbacks+1]={0,callback}
    elseif self.success == true then
        callback(unpack(NewPromise.results))
    end
end

function Promise:catch(callback)
    if self.success == nil then
        self.callbacks[#self.callbacks+1]={1,callback}
    elseif self.success == false then
        callback(unpack(self.results))
    end
end

function Promise:finally(callback)
    if self.success == nil then
        self.callbacks[#self.callbacks+1]={2,callback}
    else
        callback(not self.success,unpack(self.results))
    end
end

return Promise
