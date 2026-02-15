local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local StepTracker = require(Shared:WaitForChild("StepTracker"))

print("[Server] init.server.luau running")

-- Configuration
local SPAWN_INTERVAL = 3 -- Seconds
local X_RANGE = NumberRange.new(-50, 50) -- Min and max X coordinates
local Z_RANGE = NumberRange.new(-50, 50) -- Min and max Z coordinates
local Y_HEIGHT = 5 -- Height at which items spawn
local item_name = "Coin"

-- Ensure the spawn item exists
print("[Server] Waiting for item template:", item_name)
local itemTemplate = ReplicatedStorage:WaitForChild(item_name)
print("[Server] Item template found")

-- Leaderstats Setup
Players.PlayerAdded:Connect(function(player)
	print("[Server] PlayerAdded:", player.Name)
	StepTracker.InitPlayer(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local steps = Instance.new("IntValue")
	steps.Name = "Steps"
	steps.Value = 0
	steps.Parent = leaderstats
	print("[Server] Leaderstats initialized for:", player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
	StepTracker.RemovePlayer(player)
end)

local function spawnItem()
	if not itemTemplate then return end
	
	local clonedItem = itemTemplate:Clone()

	-- Calculate random position
	local randomX = math.random(X_RANGE.Min, X_RANGE.Max)
	local randomZ = math.random(Z_RANGE.Min, Z_RANGE.Max)
	local spawnPosition = Vector3.new(randomX, Y_HEIGHT, randomZ)

	-- Set position
	if clonedItem:IsA("Model") then
		clonedItem:PivotTo(CFrame.new(spawnPosition))
	elseif clonedItem:IsA("BasePart") then
		clonedItem.Position = spawnPosition
	end

	-- Collision Logic
	local collected = false
	clonedItem.Touched:Connect(function(otherPart)
		if collected then return end
		
		local character = otherPart.Parent
		local player = Players:GetPlayerFromCharacter(character)
		
		if player then
			collected = true
			StepTracker.AddSteps(player, 10) -- Increment steps by 10 for each coin
			clonedItem:Destroy()
			print(string.format("%s collected a coin! +10 Steps", player.Name))
		end
	end)

	-- Parent to workspace
	clonedItem.Parent = Workspace
	
	print(string.format("Spawned %s at %s", clonedItem.Name, tostring(spawnPosition)))
end

-- Spawn loop
task.spawn(function()
	while true do
		spawnItem()
		task.wait(SPAWN_INTERVAL)
	end
end)

print("Item spawner and collection system initialized.")
