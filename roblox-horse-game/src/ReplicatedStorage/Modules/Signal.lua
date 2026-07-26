-- Minimal client-side pub/sub used to notify controllers when shared state changes.
local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(fn)
	table.insert(self._handlers, fn)
	local connection = {}
	function connection.Disconnect()
		for i, handler in ipairs(self._handlers) do
			if handler == fn then
				table.remove(self._handlers, i)
				break
			end
		end
	end
	return connection
end

function Signal:Fire(...)
	for _, handler in ipairs(self._handlers) do
		task.spawn(handler, ...)
	end
end

return Signal
