local Promise = {}

function Promise.new(execute)
    local NewPromise = {
        callbacks = {},
        coroutine_function = nil,
        results = {},
        success = nil,
    }

    NewPromise.coroutine_function = coroutine.create(function()
        NewPromise.results = {pcall(execute)}
        NewPromise.success = table.remove(NewPromise.results,1)
        for _,callback in pairs(NewPromise.callbacks) do
            if callback[0] == 0 and NewPromise.success then

                callback[1](unpack(NewPromise.results)) -- call with all returned values

            elseif callback[0] == 0 and not NewPromise.success then

                callback[1](NewPromise.results[1]) -- call with error

            elseif callback[0] == 2 then

                callback[1](NewPromise.success, unpack(NewPromise.results)) -- call with success and results

            end
        end
    end)
    
    return setmetatable({
        __index = Promise
    })
end

function Promise:then(callback)
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
        callback(self.results[1])
    end
end

function Promise:finally(callback)
    if self.success == nil then
        self.callbacks[#self.callbacks+1]={2,callback}
    else
        callback(self.success,unpack(self.results))
    end
end

return Promise
