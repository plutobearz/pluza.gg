local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Increase GUI height for extra button
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "pluza.gg | Tamagotchi Party"
screenGui.Parent = player:WaitForChild("PlayerGui")
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 400) -- taller!
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.Parent = mainFrame
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "pluza.gg | Tamagotchi Party"
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "_"
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(0.7, 0, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 22
minimizeBtn.Parent = titleBar
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(0.8, 0, 0, 0)
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

local function createToggle(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = UDim2.new(0.1, 0, posY, 0)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = contentFrame
    return btn
end
local landBtn = createToggle("Land Chest Farm", 0.08)
local jadeBtn = createToggle("Jade Chest Farm", 0.28)
local skyBtn = createToggle("Sky Chest Farm", 0.48)
local waterBtn = createToggle("Water Chest Farm", 0.68)
local fruitBtn = createToggle("Fruit Stealer", 0.88)

local toggles = {
    Land = {Btn=landBtn, Active=false},
    Jade = {Btn=jadeBtn, Active=false},
    Sky = {Btn=skyBtn, Active=false},
    Water = {Btn=waterBtn, Active=false},
    Fruit = {Btn=fruitBtn, Active=false}
}

local function waitForHumanoidRootPart()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function getChests(folderName)
    local folder = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("TreasureChest")
        and workspace.Map.TreasureChest:FindFirstChild(folderName)
    if not folder then return {} end
    local chests = {}
    for _, model in pairs(folder:GetChildren()) do
        if model.Name:match("^TreasureChest_%d+$") and model:IsA("Model") then
            table.insert(chests, model)
        end
    end
    return chests
end

local function findPrompt(model)
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            return obj
        end
    end
    return nil
end

local function teleportAndClaim(chestModel)
    local hrp = waitForHumanoidRootPart()
    if hrp then
        local targetCFrame = chestModel.PrimaryPart and chestModel.PrimaryPart.CFrame or chestModel:GetPivot()
        hrp.CFrame = targetCFrame * CFrame.new(0,3,0)
        task.wait(0.08)
        local prompt = findPrompt(chestModel)
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.08)
            prompt:InputHoldEnd()
        end
    end
end

-- Fruit Stealer logic
local blacklistedFoods = {} -- persists between toggles!

local function findMyBasket()
    local baskets = workspace:FindFirstChild("Basket")
    if not baskets then return nil end
    for _, basket in pairs(baskets:GetChildren()) do
        local gui = basket:FindFirstChild("BillboardGui")
        if gui and gui:FindFirstChild("TextLabel") and gui.TextLabel.Text == player.Name then
            return basket
        end
    end
    return nil
end

local function teleportTo(part_or_model)
    local hrp = waitForHumanoidRootPart()
    if part_or_model and hrp then
        local cframe
        if part_or_model:IsA("Part") or part_or_model:IsA("MeshPart") then
            cframe = part_or_model.CFrame
        elseif part_or_model:IsA("Model") then
            cframe = part_or_model.PrimaryPart and part_or_model.PrimaryPart.CFrame or part_or_model:GetPivot()
        end
        hrp.CFrame = cframe * CFrame.new(0, 2, 0)
    end
end

local function fruitStealLoop(toggleData)
    while toggleData.Active do
        -- Find all foods not blacklisted
        local foodFolder = workspace:FindFirstChild("Food")
        if foodFolder then
            for _, food in pairs(foodFolder:GetChildren()) do
                if not blacklistedFoods[food.Name] then
                    teleportTo(food)
                    task.wait(0.2)
                    blacklistedFoods[food.Name] = true
                    local myBasket = findMyBasket()
                    if myBasket then
                        teleportTo(myBasket)
                        task.wait(0.15)
                        local prompt = findPrompt(myBasket)
                        if prompt then
                            prompt:InputHoldBegin()
                            task.wait(prompt.HoldDuration or 0.1)
                            prompt:InputHoldEnd()
                        end
                    end
                    task.wait(0.35)
                end
            end
        end
        task.wait(0.5)
    end
end

local farmingCoroutines = {}

local function farmChests(folderName, toggleData)
    while toggleData.Active do
        local chests = getChests(folderName)
        for _, chest in ipairs(chests) do
            if not toggleData.Active then break end
            teleportAndClaim(chest)
            task.wait(0.2)
        end
        task.wait(0.4)
    end
end

local function toggleFarm(typeName)
    local t = toggles[typeName]
    if t.Active then
        t.Active = false
        t.Btn.Text = typeName .. ": OFF"
        t.Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        farmingCoroutines[typeName] = nil
    else
        t.Active = true
        t.Btn.Text = typeName .. ": ON"
        t.Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        if typeName == "Fruit" then
            farmingCoroutines[typeName] = coroutine.create(function()
                fruitStealLoop(t)
            end)
        else
            farmingCoroutines[typeName] = coroutine.create(function()
                farmChests(typeName, t)
            end)
        end
        coroutine.resume(farmingCoroutines[typeName])
    end
end

landBtn.MouseButton1Click:Connect(function() toggleFarm("Land") end)
jadeBtn.MouseButton1Click:Connect(function() toggleFarm("Jade") end)
skyBtn.MouseButton1Click:Connect(function() toggleFarm("Sky") end)
waterBtn.MouseButton1Click:Connect(function() toggleFarm("Water") end)
fruitBtn.MouseButton1Click:Connect(function() toggleFarm("Fruit") end)

-- Minimize button
local minimized=false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0,300,0,30) or UDim2.new(0,300,0,220)
end)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Draggable GUI
local dragging = false
local dragInput, startPos, startFramePos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = input.Position
        startFramePos = mainFrame.Position
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
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - startPos
        mainFrame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset+delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset+delta.Y)
    end
end)
