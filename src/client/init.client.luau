print("Hello world, from client!")

-- ItemSpawner.lua
-- Place this in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local SPAWN_POSITION = Vector3.new(0, 5, 0) -- Change to where you want the item to spawn
local ITEM_NAME = "Coin" -- Name of the item in ReplicatedStorage

-- Wait for the item template to exist
local itemTemplate = ReplicatedStorage:WaitForChild(ITEM_NAME)

-- Function to spawn the item
local function spawnItem()
	local newItem = itemTemplate:Clone()
	newItem.Parent = workspace
	
	-- Set position
	if newItem:IsA("Model") then
		newItem:MoveTo(SPAWN_POSITION)
	elseif newItem:IsA("BasePart") then
		newItem.Position = SPAWN_POSITION
	end
	
	print(ITEM_NAME .. " spawned at", SPAWN_POSITION)
end

-- Spawn the item when the game starts
task.wait(3)
spawnItem()

