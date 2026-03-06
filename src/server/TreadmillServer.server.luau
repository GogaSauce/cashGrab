local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local StepTracker = require(Shared:WaitForChild("StepTracker"))

print("[TreadmillServer] Script started")

local function updatePlayerSpeed(player)
    StepTracker.UpdatePlayerSpeed(player)
end

local function onHeartbeat(dt)
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local root = character and character.PrimaryPart
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if humanoid and root and humanoid.Health > 0 then
            -- Check what the player is standing on
            -- We can use FloorMaterial and raycast for precision
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local raycastResult = workspace:Raycast(root.Position, Vector3.new(0, -6, 0), raycastParams)
            local floorPart = raycastResult and raycastResult.Instance
            
            if floorPart and (floorPart.Name == "Treadmill" or floorPart.Name == "tread") then
                -- 1. Force player to walk backward relative to Treadmill's orientation
                -- (Inverted as requested)
                local moveDirection = -floorPart.CFrame.LookVector
                humanoid:Move(moveDirection, false)
                
                -- 2. Update speed in case they gained steps
                updatePlayerSpeed(player)
                
                -- 3. Set treadmill surface velocity to match walk speed but in opposite direction
                -- This keeps the player relatively stationary on the treadmill belt
                floorPart.AssemblyLinearVelocity = moveDirection * -humanoid.WalkSpeed
                
                -- 4. Increment steps manually since their world position won't change much
                -- StepTrackerServer won't detect this movement if they stay in place
                local studsThisFrame = humanoid.WalkSpeed * dt
                local stepsToAdd = studsThisFrame / 3
                
                StepTracker.AddSteps(player, stepsToAdd)
            end
        end
    end
end

RunService.Heartbeat:Connect(onHeartbeat)
