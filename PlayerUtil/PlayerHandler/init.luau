--!strict
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

export type PlayerHandler = {
	PlayerAdded : (func : (player : Player) -> ()) -> () -> (),
	PlayerRemoving : (func : (player : Player, exitReason : Enum.PlayerExitReason) -> ()) -> () -> (),
}

local PlayerHandler = {} :: PlayerHandler
local meta = require('@self/meta')
setmetatable(PlayerHandler, meta)

local connections = {
	['PlayerAdded'] = {},
	['PlayerRemoving'] = {},
}

function PlayerHandler.PlayerAdded(func : (player : Player) -> ())
	table.insert(connections.PlayerAdded, func)
	
	for _, player in PlayerHandler do
		task.spawn(func, player)
	end
	
	return function()
		local index = table.find(connections.PlayerAdded, func)
		if not index then return end
		
		table.remove(connections.PlayerAdded, index)
	end
end

function PlayerHandler.PlayerRemoving(func : (player : Player, exitReason : Enum.PlayerExitReason) -> ())
	table.insert(connections.PlayerRemoving, func)

	return function()
		local index = table.find(connections.PlayerRemoving, func)
		if not index then return end

		table.remove(connections.PlayerRemoving, index)
	end
end

Players.PlayerAdded:Connect(function(...)
	for _, func in connections.PlayerAdded do
		task.spawn(func, ...)
	end
end)

Players.PlayerRemoving:Connect(function(...)
	for _, func in connections.PlayerRemoving do
		task.spawn(func, ...)
	end
end)

if RunService:IsServer() then
	game:BindToClose(function()
		for _, player in PlayerHandler do
			for _, func in connections.PlayerRemoving do
				task.spawn(func, player, Enum.PlayerExitReason.Unknown)
			end
		end
	end)
end

return PlayerHandler