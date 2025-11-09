--!strict
local Players = game:GetService('Players')

return {
	__call = function(_, s : string | number | Model) : Player?
		local player = nil

		if typeof(s) == 'string' then
			player = Players:FindFirstChild(s)
		elseif typeof(s) == 'number' then
			player = Players:GetPlayerByUserId(s)
		elseif typeof(s) == 'Instance' and s:IsA('Model') then
			player = Players:GetPlayerFromCharacter(s)
		end

		return player
	end,
	__index = function(_, s : string | number | Model) : Player?
		local player = nil

		if typeof(s) == 'string' then
			player = Players:FindFirstChild(s)
		elseif typeof(s) == 'number' then
			player = Players:GetPlayerByUserId(s)
		elseif typeof(s) == 'Instance' and s:IsA('Model') then
			player = Players:GetPlayerFromCharacter(s)
		end

		return player
	end,
	__len = function(_)
		return #Players:GetPlayers()
	end,
	__iter = function()
		return next, Players:GetPlayers()
	end,
}