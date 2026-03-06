local StepTracker = {}

-- Public table for player data
StepTracker.PlayerData = {}

-- Function to initialize a player's data
function StepTracker.InitPlayer(player)
    print("[StepTracker] Initializing player:", player.Name)
    if not StepTracker.PlayerData[player.UserId] then
        StepTracker.PlayerData[player.UserId] = {
            Steps = 0,
            Rebirths = 0,
            Multiplier = 1.0,
            EquippedPets = {} -- List of pet names or IDs
        }
    end
end

-- Function to calculate speed based on steps
function StepTracker.CalculateSpeed(steps)
    -- formula: 4 + a * ln(bx + 1) steps/sec
    -- multiply by 3 to convert to studs/sec
    local stepsPerSec = 4 + 5 * math.log(0.1 * steps + 1)
    return stepsPerSec * 3
end

-- Function to update a player's walkspeed (Server side)
function StepTracker.UpdatePlayerSpeed(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local data = StepTracker.PlayerData[player.UserId]
        local steps = data and data.Steps or 0
        local newSpeed = StepTracker.CalculateSpeed(steps)
        humanoid.WalkSpeed = newSpeed
    end
end


-- Function to get rebirth cost
function StepTracker.GetRebirthCost(rebirths)
    -- Cost = 1000 * (x^2) + 5000
    return 1000 * (rebirths ^ 2) + 5000
end

-- Function to calculate total multiplier including pets
function StepTracker.GetTotalMultiplier(player)
    local data = StepTracker.PlayerData[player.UserId]
    if not data then return 1.0 end
    
    local totalMultiplier = data.Multiplier -- Base multiplier from rebirths
    
    -- Multiplicative pet bonuses: each pet adds a 1.15x multiplier
    if data.EquippedPets then
        for _ in pairs(data.EquippedPets) do
            totalMultiplier *= 1.15
        end
    end
    
    return totalMultiplier
end

-- Function to add steps
function StepTracker.AddSteps(player, amount)
    local data = StepTracker.PlayerData[player.UserId]
    if data then
        local totalMultiplier = StepTracker.GetTotalMultiplier(player)
        local boostedAmount = amount * totalMultiplier
        data.Steps += boostedAmount
        
        -- Update leaderstats if it exists
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local stepsValue = leaderstats:FindFirstChild("Steps")
            if stepsValue then
                stepsValue.Value = math.floor(data.Steps)
            else
                warn("[StepTracker] Steps leaderstat not found for player:", player.Name)
            end
        else
            warn("[StepTracker] leaderstats not found for player:", player.Name)
        end
    else
        warn("[StepTracker] Player not initialized in StepTracker:", player.Name)
    end
end

-- Function to clean up when a player leaves
function StepTracker.RemovePlayer(player)
    StepTracker.PlayerData[player.UserId] = nil
end

return StepTracker
