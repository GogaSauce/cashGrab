local StepTracker = {}

-- Public table for player step counts
StepTracker.PlayerSteps = {}

-- Function to initialize a player's step count
function StepTracker.InitPlayer(player)
    print("[StepTracker] Initializing player:", player.Name)
    if not StepTracker.PlayerSteps[player.UserId] then
        StepTracker.PlayerSteps[player.UserId] = 0
    end
end

-- Function to add steps
function StepTracker.AddSteps(player, amount)
    if StepTracker.PlayerSteps[player.UserId] then
        StepTracker.PlayerSteps[player.UserId] += amount
        -- Update leaderstats if it exists
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local stepsValue = leaderstats:FindFirstChild("Steps")
            if stepsValue then
                stepsValue.Value = math.floor(StepTracker.PlayerSteps[player.UserId])
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

-- Function to multiply steps
function StepTracker.MultiplySteps(player, multiplier)
    if StepTracker.PlayerSteps[player.UserId] then
        StepTracker.PlayerSteps[player.UserId] *= multiplier
        -- Update leaderstats if it exists
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local stepsValue = leaderstats:FindFirstChild("Steps")
            if stepsValue then
                stepsValue.Value = math.floor(StepTracker.PlayerSteps[player.UserId])
            end
        end
    end
end

-- Function to clean up when a player leaves
function StepTracker.RemovePlayer(player)
    StepTracker.PlayerSteps[player.UserId] = nil
end

return StepTracker
