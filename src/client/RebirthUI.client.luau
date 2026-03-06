local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local StepTracker = require(Shared:WaitForChild("StepTracker"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local player = Players.LocalPlayer
local remotesFolder = Remotes.Init()
local rebirthRequest = remotesFolder:WaitForChild("RebirthRequest")

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RebirthGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Shop Button
local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(0, 150, 0, 50)
shopButton.Position = UDim2.new(0, 20, 0.5, -25)
shopButton.BackgroundColor3 = Color3.fromRGB(40, 150, 255)
shopButton.Text = "Rebirth Shop"
shopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shopButton.Font = Enum.Font.GothamBold
shopButton.TextSize = 18
shopButton.Parent = screenGui

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = shopButton

-- Rebirth Panel
local panel = Instance.new("Frame")
panel.Name = "RebirthPanel"
panel.Size = UDim2.new(0, 400, 0, 450)
panel.Position = UDim2.new(0.5, -200, 1.5, 0) -- Hidden initially
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(60, 60, 70)
panelStroke.Thickness = 2
panelStroke.Parent = panel

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "REBIRTH SHOP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.Parent = panel

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Info Container
local infoContainer = Instance.new("Frame")
infoContainer.Name = "Info"
infoContainer.Size = UDim2.new(0.9, 0, 0.6, 0)
infoContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
infoContainer.BackgroundTransparency = 1
infoContainer.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = infoContainer

local function createStatLabel(name, labelText)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, 0, 0, 40)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(200, 200, 205)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 18
	label.Parent = infoContainer
	return label
end

local stepsLabel = createStatLabel("StepsLabel", "Current Steps: 0")
local rebirthsLabel = createStatLabel("RebirthsLabel", "Rebirths: 0")
local multiplierLabel = createStatLabel("MultiplierLabel", "Step Multiplier: 1.00x")
local costLabel = createStatLabel("CostLabel", "Cost for Next Rebirth: 5,000")

-- Rebirth Button
local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Size = UDim2.new(0.8, 0, 0, 60)
rebirthButton.Position = UDim2.new(0.1, 0, 0.8, 0)
rebirthButton.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
rebirthButton.Text = "REBIRTH"
rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.Font = Enum.Font.GothamBlack
rebirthButton.TextSize = 22
rebirthButton.Parent = panel

local rbCorner = Instance.new("UICorner")
rbCorner.CornerRadius = UDim.new(0, 10)
rbCorner.Parent = rebirthButton

-- Error Message
local errorLabel = Instance.new("TextLabel")
errorLabel.Name = "ErrorLabel"
errorLabel.Size = UDim2.new(1, 0, 0, 30)
errorLabel.Position = UDim2.new(0, 0, 0.93, 0)
errorLabel.BackgroundTransparency = 1
errorLabel.Text = ""
errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
errorLabel.Font = Enum.Font.GothamMedium
errorLabel.TextSize = 14
errorLabel.Parent = panel

-- Logic
local isOpen = false

local function updateUI()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local steps = leaderstats:FindFirstChild("Steps")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	
	if steps and rebirths then
		local rVal = rebirths.Value
		local cost = StepTracker.GetRebirthCost(rVal)
		local multiplier = math.pow(1.15, rVal)
		
		stepsLabel.Text = "Current Steps: " .. steps.Value
		rebirthsLabel.Text = "Rebirths: " .. rVal
		multiplierLabel.Text = string.format("Step Multiplier: %.2fx", multiplier)
		costLabel.Text = string.format("Cost for Next Rebirth: %s", tostring(cost))
		
		if steps.Value >= cost then
			rebirthButton.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
			errorLabel.Text = ""
		else
			rebirthButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end
	end
end

local function togglePanel(state)
	isOpen = state
	local targetPos = state and UDim2.new(0.5, -200, 0.5, -225) or UDim2.new(0.5, -200, 1.5, 0)
	local tween = TweenService:Create(panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos})
	tween:Play()
	
	if state then
		updateUI()
	end
end

shopButton.MouseButton1Click:Connect(function()
	togglePanel(not isOpen)
end)

closeButton.MouseButton1Click:Connect(function()
	togglePanel(false)
end)

rebirthButton.MouseButton1Click:Connect(function()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local steps = leaderstats:FindFirstChild("Steps")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	
	if steps and rebirths then
		local cost = StepTracker.GetRebirthCost(rebirths.Value)
		if steps.Value >= cost then
			rebirthRequest:FireServer()
			-- Visual feedback
			local flash = Instance.new("Frame")
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			flash.BackgroundTransparency = 0.5
			flash.ZIndex = 10
			flash.Parent = screenGui
			TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
			task.delay(0.3, function() flash:Destroy() end)
		else
			errorLabel.Text = "Need " .. (cost - steps.Value) .. " more steps!"
			-- Shake effect
			local originalPos = panel.Position
			task.spawn(function()
				for i = 1, 6 do
					panel.Position = originalPos + UDim2.new(0, math.random(-5, 5), 0, 0)
					task.wait(0.05)
				end
				panel.Position = originalPos
			end)
		end
	end
end)

-- Update thread
task.spawn(function()
	while true do
		if isOpen then
			updateUI()
		end
		task.wait(0.5)
	end
end)
