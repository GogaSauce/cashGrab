local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("[Client] Step UI script running for:", player.Name)

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StepGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 50)
mainFrame.Position = UDim2.new(0, 20, 1, -70)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local stepLabel = Instance.new("TextLabel")
stepLabel.Name = "StepLabel"
stepLabel.Size = UDim2.new(1, -20, 1, 0)
stepLabel.Position = UDim2.new(0, 10, 0, 0)
stepLabel.BackgroundTransparency = 1
stepLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
stepLabel.TextSize = 24
stepLabel.Font = Enum.Font.GothamMedium
stepLabel.TextXAlignment = Enum.TextXAlignment.Left
stepLabel.Text = "Steps: 0"
stepLabel.Parent = mainFrame

-- Update Logic
local function updateStepDisplay(newValue)
	stepLabel.Text = "Steps: " .. tostring(newValue)
end

-- Wait for leaderstats
print("[Client] Waiting for leaderstats...")
local leaderstats = player:WaitForChild("leaderstats")
print("[Client] leaderstats found, waiting for Steps...")
local stepsValue = leaderstats:WaitForChild("Steps")
print("[Client] Steps found:", stepsValue.Value)

-- Initial update
updateStepDisplay(stepsValue.Value)

-- Listen for changes
stepsValue:GetPropertyChangedSignal("Value"):Connect(function()
	print("[Client] Steps updated to:", stepsValue.Value)
	updateStepDisplay(stepsValue.Value)
end)

print("Step UI initialized.")
