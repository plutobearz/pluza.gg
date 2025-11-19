local player = game.Players.LocalPlayer

-- Create a separate ScreenGui and Title Label that will stay forever until Finished is pressed
local titleGui = Instance.new("ScreenGui", player.PlayerGui)
titleGui.Name = "PersistentTitleGui"

local title = Instance.new("TextLabel", titleGui)
title.Size = UDim2.new(0, 500, 0, 60)
title.Position = UDim2.new(0.5, -250, 0.2, 0)
title.BackgroundTransparency = 1
title.Text = "pluza.gg | Easy Obby Finish UGC"
title.Font = Enum.Font.FredokaOne
title.TextScaled = true
title.TextStrokeTransparency = 0.25
title.TextStrokeColor3 = Color3.fromRGB(255, 0, 255)

-- Rainbow text cycling coroutine
local running = true
spawn(function()
    while running do
        for hue = 0, 1, 0.01 do
            if not running then break end
            title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            wait(0.03)
        end
    end
end)

-- Create Loading progress GUI (separate)
local loadingGui = Instance.new("ScreenGui", player.PlayerGui)
loadingGui.Name = "ObbyLoaderGUI"

local frame = Instance.new("Frame", loadingGui)
frame.Size = UDim2.new(0, 420, 0, 64)
frame.Position = UDim2.new(0.5, -210, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)

local bar = Instance.new("Frame", frame)
bar.Name = "Bar"
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
bar.BorderSizePixel = 0

local glow = Instance.new("Frame", frame)
glow.Size = UDim2.new(1, 0, 1, 0)
glow.Position = UDim2.new(0, 0, 0, 0)
glow.BackgroundTransparency = 0.8
glow.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
glow.ZIndex = 0

local percentLabel = Instance.new("TextLabel", frame)
percentLabel.Size = UDim2.new(1, 0, 1, 0)
percentLabel.Position = UDim2.new(0, 0, 0, 0)
percentLabel.BackgroundTransparency = 1
percentLabel.TextScaled = true
percentLabel.Font = Enum.Font.FredokaOne
percentLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
percentLabel.TextStrokeColor3 = Color3.fromRGB(255, 0, 255)
percentLabel.TextStrokeTransparency = 0.2
percentLabel.Text = "Loading: 1%"

-- Teleport through checkpoints with progress update
local numStages = 62
for i = 1, numStages do
    local checkpoint = workspace.Checkpoints:FindFirstChild(tostring(i))
    if checkpoint and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = checkpoint.CFrame + Vector3.new(0, 3, 0)
    end
    local percent = math.floor(i / numStages * 100)
    bar:TweenSize(UDim2.new(i / numStages, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    percentLabel.Text = "Loading: " .. percent .. "%"
    wait(0.13)
end

wait(1)

-- Remove only the loading GUI (progress bar frame)
loadingGui:Destroy()

-- Create Finished GUI (without title, title stays in separate GUI)
local finishedGui = Instance.new("ScreenGui", player.PlayerGui)
finishedGui.Name = "ObbyFinishedGUI"

local finFrame = Instance.new("Frame", finishedGui)
finFrame.Size = UDim2.new(0, 500, 0, 200)
finFrame.Position = UDim2.new(0.5, -250, 0.4, 0)
finFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
finFrame.BorderSizePixel = 2
finFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
finFrame.ClipsDescendants = true

local finTitle = Instance.new("TextLabel", finFrame)
finTitle.Size = UDim2.new(1, 0, 0, 50)
finTitle.Position = UDim2.new(0, 0, 0, 10)
finTitle.BackgroundTransparency = 1
finTitle.Text = "Make sure to join the discord (https://discord.gg/wzHzQveM2f)"
finTitle.Font = Enum.Font.FredokaOne
finTitle.TextStrokeColor3 = Color3.fromRGB(255, 0, 255)
finTitle.TextStrokeTransparency = 0.25
finTitle.TextScaled = true
finTitle.TextWrapped = true

local copyButton = Instance.new("TextButton", finFrame)
copyButton.Size = UDim2.new(0, 280, 0, 40)
copyButton.Position = UDim2.new(0.5, -140, 0, 70)
copyButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
copyButton.TextColor3 = Color3.new(1,1,1)
copyButton.Font = Enum.Font.FredokaOne
copyButton.TextSize = 24
copyButton.Text = "Copy Discord Link"
copyButton.AutoButtonColor = true

local popup = Instance.new("Frame", finishedGui)
popup.Size = UDim2.new(0, 350, 0, 100)
popup.Position = UDim2.new(0.5, -175, 0.3, 0)
popup.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
popup.BorderColor3 = Color3.fromRGB(0, 255, 255)
popup.BorderSizePixel = 2
popup.Visible = false

local popupText = Instance.new("TextLabel", popup)
popupText.Size = UDim2.new(1,0,1,0)
popupText.BackgroundTransparency = 1
popupText.Text = "Discord link copied to clipboard!"
popupText.Font = Enum.Font.FredokaOne
popupText.TextColor3 = Color3.fromRGB(0,255,0)
popupText.TextScaled = true
popupText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
popupText.TextStrokeTransparency = 0.1

local closeBtn = Instance.new("TextButton", popup)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 20
closeBtn.Text = "X"
closeBtn.MouseButton1Click:Connect(function()
    popup.Visible = false
end)

local finishedButton = Instance.new("TextButton", finFrame)
finishedButton.Size = UDim2.new(0,120,0,50)
finishedButton.Position = UDim2.new(0.5, -60, 1, -70)
finishedButton.BackgroundColor3 = Color3.fromRGB(0,255,0)
finishedButton.TextColor3 = Color3.new(1,1,1)
finishedButton.Font = Enum.Font.FredokaOne
finishedButton.TextSize = 26
finishedButton.Text = "Finished"

copyButton.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/wzHzQveM2f")
    popup.Visible = true
end)

finishedButton.MouseButton1Click:Connect(function()
    titleGui:Destroy()  -- remove persistent rainbow title only when finishing
    finishedGui:Destroy()
end)
