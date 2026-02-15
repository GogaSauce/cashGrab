local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local StepTracker = require(Shared:WaitForChild("StepTracker"))

print("[StepTrackerServer] Script running")

local lastPositions = {}

local function calculateSpeed(steps)
    -- formula: 4 + a * ln(bx + 1) steps/sec
    -- multiply by 3 to convert to studs/sec
    local stepsPerSec =  4+ 5 * math.log(0.1 * steps + 1)
    return stepsPerSec * 3
end

local function updatePlayerSpeed(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local steps = StepTracker.PlayerSteps[player.UserId] or 0
        local newSpeed = calculateSpeed(steps)
        humanoid.WalkSpeed = newSpeed
    end
end

local function onHeartbeat()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character.PrimaryPart then
            local root = character.PrimaryPart
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            -- Only track distance if the player is on the ground
            local state = humanoid and humanoid:GetState()
            if state and state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.Jumping then
                local currentPos = root.Position
                local lastPos = lastPositions[player.UserId]
                
                if lastPos then
                    -- Calculate horizontal distance traveled (ignore Y axis for "steps")
                    local studsTraveled = (Vector2.new(currentPos.X, currentPos.Z) - Vector2.new(lastPos.X, lastPos.Z)).Magnitude
                    
                    if studsTraveled > 0.15 then -- Adjusted threshold (0.05 steps)
                        local stepsToAdd = studsTraveled / 3
                        StepTracker.AddSteps(player, stepsToAdd)
                        updatePlayerSpeed(player)
                    end
                else
                    -- Initial set of speed if no last position (like when they respawn/join)
                    updatePlayerSpeed(player)
                end
                
                lastPositions[player.UserId] = currentPos
            else
                -- Reset last position if they are in the air or humanoid missing
                lastPositions[player.UserId] = nil
            end
        end
    end
end

-- Ensure speed is updated when steps are changed outside (e.g. coin collection)
-- Coin collection happens in init.server.luau which calls StepTracker.AddSteps.
-- Since heartbeat runs every frame, it will catch the new step count and update speed next frame.
-- However, for immediate feedback, we can listen for leaderstat changes if needed.
-- But the heartbeat logic above handles it via updatePlayerSpeed call during movement.

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Set initial speed on spawn
        task.wait(0.1) -- Small wait to ensure humanoid is loaded
        updatePlayerSpeed(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    lastPositions[player.UserId] = nil
end)

RunService.Heartbeat:Connect(onHeartbeat)
print("[StepTrackerServer] Heartbeat connected")
