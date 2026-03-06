-- PetTest.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local StepTracker = require(Shared:WaitForChild("StepTracker"))

print("[PetTest] Verification script loaded")

local function runTest(player)
    task.wait(3) -- Ensure services are ready
    print("[PetTest] Starting test for player:", player.Name)
    
    local PetFollowService = _G.PetFollowService
    if not PetFollowService then
        warn("[PetTest] PetFollowService not found in _G")
        return
    end

    -- 1. Check initial multiplier
    local initialMult = StepTracker.GetTotalMultiplier(player)
    print(string.format("[PetTest] Initial Multiplier: %.2fx", initialMult))
    
    -- 2. Equip 1 pet
    print("[PetTest] Equipping Dog...")
    PetFollowService.EquipPet(player, "SimpleDog")
    local onePetMult = StepTracker.GetTotalMultiplier(player)
    print(string.format("[PetTest] One Pet Multiplier: %.2fx (Expected 1.15x)", onePetMult))
    
    -- 3. Equip 2nd pet
    print("[PetTest] Equipping Cat...")
    PetFollowService.EquipPet(player, "SimpleCat")
    local twoPetMult = StepTracker.GetTotalMultiplier(player)
    print(string.format("[PetTest] Two Pet Multiplier: %.4fx (Expected 1.3225x)", twoPetMult))
    
    -- 4. Verify formation
    print("[PetTest] Verification logic finished. Check character visually.")
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        runTest(player)
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        task.spawn(runTest, player)
    end
end
