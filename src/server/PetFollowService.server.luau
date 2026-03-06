local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local StepTracker = require(Shared:WaitForChild("StepTracker"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local remotesFolder = Remotes.Init()
local petEquipRequest = remotesFolder:WaitForChild("PetEquipRequest")

local PetFollowService = {}
local activePets = {} -- [PlayerUserId] = {{Name: string, Part: Part}}

-- Formation settings
local FOLLOW_DISTANCE = 5
local SPREAD_ANGLE = 0.5 -- radians between pets
local PET_FLOAT_HEIGHT = 1.0

local function createPetPart(player)
    local pet = Instance.new("Part")
    pet.Name = player.Name .. "_Pet"
    pet.Size = Vector3.new(1.5, 1.5, 1.5)
    pet.Color = Color3.fromHSV(math.random(), 0.7, 0.9)
    pet.Shape = Enum.PartType.Ball
    pet.CanCollide = false
    pet.Material = Enum.Material.SmoothPlastic
    
    -- Physics constraints
    local attachment = Instance.new("Attachment")
    attachment.Parent = pet
    
    local alignPos = Instance.new("AlignPosition")
    alignPos.Attachment0 = attachment
    alignPos.Mode = Enum.PositionAlignmentMode.TwoAttachment
    alignPos.MaxForce = 15000
    alignPos.Responsiveness = 15
    alignPos.Parent = pet
    
    local alignOri = Instance.new("AlignOrientation")
    alignOri.Attachment0 = attachment
    alignOri.Mode = Enum.OrientationAlignmentMode.TwoAttachment
    alignOri.MaxTorque = 15000
    alignOri.Responsiveness = 15
    alignOri.Parent = pet
    
    pet.Parent = workspace
    return pet
end

local function updatePetPositions()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        local pPets = activePets[player.UserId]
        if not pPets or #pPets == 0 then continue end
        
        local numPets = #pPets
        local startAngle = -(numPets - 1) * SPREAD_ANGLE / 2
        
        for i, petData in ipairs(pPets) do
            local angle = startAngle + (i - 1) * SPREAD_ANGLE
            
            -- Calculate offset behind the player
            -- We use root.CFrame and move it back and rotate it
            -- CFrame.new(0, height, distance) moves it relative to root
            -- Then we rotate around Y axis
            local offsetCFrame = root.CFrame * CFrame.Angles(0, angle, 0) * CFrame.new(0, PET_FLOAT_HEIGHT, FOLLOW_DISTANCE)
            
            local pet = petData.Part
            local alignPos = pet:FindFirstChildOfClass("AlignPosition")
            local alignOri = pet:FindFirstChildOfClass("AlignOrientation")
            
            -- Create/Update target attachment on root if needed
            local attachmentName = "PetAttachment_" .. i
            local targetAttachment = root:FindFirstChild(attachmentName)
            if not targetAttachment then
                targetAttachment = Instance.new("Attachment")
                targetAttachment.Name = attachmentName
                targetAttachment.Parent = root
            end
            
            targetAttachment.WorldCFrame = offsetCFrame
            
            alignPos.Attachment1 = targetAttachment
            alignOri.Attachment1 = targetAttachment
        end
    end
end

RunService.Heartbeat:Connect(updatePetPositions)

-- Handle Pet Equipment
function PetFollowService.EquipPet(player, petName)
    local data = StepTracker.PlayerData[player.UserId]
    if not data then return end
    
    -- Add to data table (for multiplier)
    table.insert(data.EquippedPets, petName)
    
    -- Instantiate physical pet
    if not activePets[player.UserId] then
        activePets[player.UserId] = {}
    end
    
    local petPart = createPetPart(player)
    table.insert(activePets[player.UserId], {Name = petName, Part = petPart})
    
    print(string.format("[PetFollowService] %s equipped pet: %s. Total pets: %d", player.Name, petName, #data.EquippedPets))
end

petEquipRequest.OnServerEvent:Connect(function(player, petName)
    PetFollowService.EquipPet(player, petName)
end)

_G.PetFollowService = PetFollowService -- Global registration for easy testing

Players.PlayerRemoving:Connect(function(player)
    local pPets = activePets[player.UserId]
    if pPets then
        for _, petData in ipairs(pPets) do
            if petData.Part then
                petData.Part:Destroy()
            end
        end
        activePets[player.UserId] = nil
    end
end)

print("[PetFollowService] Initialized")
