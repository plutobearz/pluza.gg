local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Checkpoints folder
local CHECKPOINTS = workspace:WaitForChild("Checkpoints")
local INTERVAL = 0.3 -- 0.3 seconds between teleports

local LOOPING = false
local loopConnection
local currentCheckpoint = 1
local totalCheckpoints = 73

-- Collect all checkpoints (works with MODELS)
local checkpoints = {}
for i = 1, totalCheckpoints do
    local cp = CHECKPOINTS:FindFirstChild(tostring(i))
    if cp then
        table.insert(checkpoints, cp)
    end
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheckpointLoopGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "CHECKPOINTS 1-73 (STOPS AT 73)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
toggleBtn.Text = "START: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = toggleBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 35)
statusLabel.Position = UDim2.new(0.05, 0, 0, 120)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Found " .. #checkpoints .. "/73 checkpoints"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Progress Label
local progressLabel = Instance.new("TextLabel")
progressLabel.Size = UDim2.new(0.9, 0, 0, 25)
progressLabel.Position = UDim2.new(0.05, 0, 0, 160)
progressLabel.BackgroundTransparency = 1
progressLabel.Text = "Ready to start"
progressLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
progressLabel.TextScaled = true
progressLabel.Font = Enum.Font.Gotham
progressLabel.Parent = mainFrame

-- **FIXED** Teleport function - STOPS AT 73
local function teleportToCheckpoint(index)
    -- STOP CONDITION - Don't go past 73
    if index > #checkpoints then
        statusLabel.Text = "FINISHED! Reached Checkpoint " .. #checkpoints
        progressLabel.Text = "Complete! Toggle OFF to reset"
        LOOPING = false
        toggleBtn.Text = "FINISHED"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        if loopConnection then
            task.cancel(loopConnection)
        end
        return
    end
    
    local checkpoint = checkpoints[index]
    if checkpoint and checkpoint.Parent then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Use GetPivot() for models
            local modelPivot = checkpoint:GetPivot()
            char.HumanoidRootPart.CFrame = modelPivot + Vector3.new(0, 5, 0)
            
            statusLabel.Text = "Checkpoint " .. index .. "/" .. #checkpoints
            progressLabel.Text = "Checkpoint " .. index .. " → Next in 0.3s"
        end
    else
        statusLabel.Text = "Checkpoint " .. index .. " missing!"
        progressLabel.Text = "Skipping..."
        currentCheckpoint = currentCheckpoint + 1 -- Skip missing ones
    end
end

-- Toggle sequence (1-73 only)
toggleBtn.MouseButton1Click:Connect(function()
    if LOOPING then
        -- Stop early if running
        LOOPING = false
        toggleBtn.Text = "START: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        statusLabel.Text = "Stopped early"
        progressLabel.Text = "Stopped at Checkpoint " .. currentCheckpoint
        if loopConnection then
            task.cancel(loopConnection)
        end
    else
        -- Start fresh from 1
        LOOPING = true
        toggleBtn.Text = "RUNNING"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        statusLabel.Text = "Running 1-73 sequence"
        progressLabel.Text = "Checkpoint 1 → Next in 0.3s"
        currentCheckpoint = 1
        
        -- First teleport
        teleportToCheckpoint(1)
        
        -- Start sequence
        loopConnection = task.spawn(function()
            while LOOPING and currentCheckpoint <= #checkpoints do
                task.wait(INTERVAL)
                currentCheckpoint = currentCheckpoint + 1
                teleportToCheckpoint(currentCheckpoint)
            end
        end)
    end
end)

-- Error check
if #checkpoints == 0 then
    statusLabel.Text = "ERROR: No checkpoints found!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleBtn.Text = "ERROR"
end

-- Draggable GUI
local draggingFrame, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFrame and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                          input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = false
    end
end)

print("=== CHECKPOINT 1-73 (STOPS AT 73) LOADED ===")
print("• Found " .. #checkpoints .. "/73 checkpoints")
print("• Runs 1→2→3→...→73 then STOPS")
print("• Exactly 0.3s intervals")
print("• Click again to stop early or restart")
