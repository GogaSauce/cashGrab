local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local StepTracker = require(Shared:WaitForChild("StepTracker"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local remotesFolder = Remotes.Init()
local rebirthRequest = remotesFolder:WaitForChild("RebirthRequest")

rebirthRequest.OnServerEvent:Connect(function(player)
	local data = StepTracker.PlayerData[player.UserId]
	if not data then return end
	
	local cost = StepTracker.GetRebirthCost(data.Rebirths)
	
	if data.Steps >= cost then
		-- Execute Rebirth
		data.Steps = 0
		data.Rebirths += 1
		data.Multiplier *= 1.15
		
		-- Update leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local stepsValue = leaderstats:FindFirstChild("Steps")
			local rebirthsValue = leaderstats:FindFirstChild("Rebirths")
			
			if stepsValue then stepsValue.Value = 0 end
			if rebirthsValue then rebirthsValue.Value = data.Rebirths end
		end
		
		print(string.format("[RebirthService] %s rebirthed! New Multiplier: %.2fx", player.Name, data.Multiplier))
	else
		warn(string.format("[RebirthService] %s failed to rebirth. Needs %d more steps.", player.Name, math.ceil(cost - data.Steps)))
	end
end)
