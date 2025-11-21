local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "pluza.gg | Wicked RP"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200) -- Height increased for new button
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "pluza.gg | Wicked RP"
titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "_"
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(0.8, 0, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 22
minimizeBtn.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = titleBar

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
contentFrame.Parent = mainFrame

local emeraldToggle = Instance.new("TextButton")
emeraldToggle.Text = "Emerald Farm: OFF"
emeraldToggle.Size = UDim2.new(0.8, 0, 0, 50)
emeraldToggle.Position = UDim2.new(0.1, 0, 0.1, 0)
emeraldToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
emeraldToggle.TextColor3 = Color3.new(1,1,1)
emeraldToggle.Font = Enum.Font.GothamBold
emeraldToggle.TextSize = 20
emeraldToggle.Parent = contentFrame

local serverHopButton = Instance.new("TextButton")
serverHopButton.Text = "Server Hop"
serverHopButton.Size = UDim2.new(0.8, 0, 0, 50)
serverHopButton.Position = UDim2.new(0.1, 0, 0.5, 0)
serverHopButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
serverHopButton.TextColor3 = Color3.new(1,1,1)
serverHopButton.Font = Enum.Font.GothamBold
serverHopButton.TextSize = 20
serverHopButton.Parent = contentFrame

-- Teleport logic
local isFarming = false
local emeraldSpawns = {}

local function updateEmeraldSpawns()
    emeraldSpawns = {}
    local folder = workspace:FindFirstChild("EmeraldSpawns")
    if folder then
        for _, part in pairs(folder:GetChildren()) do
            if part.Name == "EmeraldSpawn" and part:IsA("BasePart") then
                table.insert(emeraldSpawns, part)
            end
        end
    end
end
updateEmeraldSpawns()

local farmCoroutine

local function farmEmeralds()
    while isFarming do
        for _, spawnPart in pairs(emeraldSpawns) do
            if not isFarming then break end
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and spawnPart and spawnPart:IsDescendantOf(workspace) then
                hrp.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
            end
            task.wait(0.1)
        end
        task.wait(0.1)
    end
end

emeraldToggle.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        emeraldToggle.Text = "Emerald Farm: ON"
        emeraldToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        if not farmCoroutine or coroutine.status(farmCoroutine) == "dead" then
            farmCoroutine = coroutine.create(farmEmeralds)
            coroutine.resume(farmCoroutine)
        end
    else
        emeraldToggle.Text = "Emerald Farm: OFF"
        emeraldToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    end
end)

serverHopButton.MouseButton1Click:Connect(function()
    local teleportOptions = Instance.new("TeleportOptions")
    TeleportService:Teleport(game.PlaceId, player, teleportOptions)
end)

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    contentFrame.Visible = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
    else
        mainFrame.Size = UDim2.new(0, 300, 0, 200)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Draggable GUI
local dragging = false
local dragInput, mousePos, framePos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)
