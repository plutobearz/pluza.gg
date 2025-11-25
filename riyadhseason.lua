-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Utility to get first BasePart inside a model
local function getFirstBasePart(model)
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

-- Teleport function that teleports to the first BasePart found in model
local function teleportToModel(model)
    local part = getFirstBasePart(model)
    if part then
        HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    end
end

-- Proximity prompt trigger function
local function interactProximityPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt:InputHoldBegin()
        wait(0.3)
        prompt:InputHoldEnd()
    end
end

-- Blacklist maker
local function makeBlacklist()
    return setmetatable({}, {
        __index = function(t, k)
            rawset(t, k, false)
            return false
        end,
    })
end

-- Autofarm generic folder with blacklist and spawnName
local function autofarmFolder(folder, spawnName, blacklist)
    for _, spawn in ipairs(folder:GetChildren()) do
        if spawn.Name == spawnName and not blacklist[spawn] then
            blacklist[spawn] = true
            teleportToModel(spawn)
            wait(0.5)
            return true
        end
    end
    -- Reset blacklist if all visited
    local allVisited = true
    for _, spawn in ipairs(folder:GetChildren()) do
        if spawn.Name == spawnName and not blacklist[spawn] then
            allVisited = false
            break
        end
    end
    if allVisited then
        for k in pairs(blacklist) do
            blacklist[k] = false
        end
    end
    return false
end

-- Autofarm chests specifically activating proximity prompt
local function autofarmChests(folder, blacklist)
    for _, chestSpawn in ipairs(folder:GetChildren()) do
        if chestSpawn.Name == "ChestSpawn" and not blacklist[chestSpawn] then
            blacklist[chestSpawn] = true
            teleportToModel(chestSpawn)
            wait(0.3)
            local prompt = chestSpawn:FindFirstChild("UnderwaterChesstSpawn") and
                           chestSpawn.UnderwaterChesstSpawn:FindFirstChild("UnderwaterChest") and
                           chestSpawn.UnderwaterChesstSpawn.UnderwaterChest.ProximityPosition:FindFirstChild("ProximityPrompt")
            interactProximityPrompt(prompt)
            wait(0.3)
            return true
        end
    end
    -- Reset blacklist if all visited
    local allVisited = true
    for _, chestSpawn in ipairs(folder:GetChildren()) do
        if chestSpawn.Name == "ChestSpawn" and not blacklist[chestSpawn] then
            allVisited = false
            break
        end
    end
    if allVisited then
        for k in pairs(blacklist) do
            blacklist[k] = false
        end
    end
    return false
end

-- Create main GUI frame with draggable, minimizable, and closable functionality
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoFarmGUI"

local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 600)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true -- Makes the frame draggable

-- Header bar
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local title = Instance.new("TextLabel", header)
title.Text = "AutoFarm Controls"
title.Size = UDim2.new(0.7, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0.03, 0, 0, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Minimize Button
local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 40, 1, 0)
minimizeBtn.Position = UDim2.new(0.7, 0, 0, 0)
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 20

-- Close Button
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 40, 1, 0)
closeBtn.Position = UDim2.new(0.85, 0, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 20

-- Scrolling frame for toggles
local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Position = UDim2.new(0, 0, 0, 30)
scrollingFrame.Size = UDim2.new(1, 0, 1, -30)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 8

-- Create toggle buttons
local toggles = {}
local function createToggleButton(name, parent, posY)
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(0.9, 0, 0, 50)
    toggleFrame.Position = UDim2.new(0.05, 0, 0, posY)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    toggleFrame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", toggleFrame)
    label.Text = name
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0.03, 0, 0, 0)

    local button = Instance.new("TextButton", toggleFrame)
    button.Size = UDim2.new(0.25, 0, 0.8, 0)
    button.Position = UDim2.new(0.7, 0, 0.1, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Text = "OFF"

    local enabled = false
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = enabled and "ON" or "OFF"
        button.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        toggles[name].enabled = enabled
    end)

    toggles[name] = {enabled = false}
end

-- List of categories as per your spawns:
local categories = {
    "ShellSpawns", "ShushiSpawns", "TacoSpawns", "PyramidSpawns",
    "PizzaSpawns", "NoodleSpawns", "KuwaitTowerSpawns", "GorengSpawns",
    "CroissantSpawns", "ChestSpawns", "CamelSpawns", "Diamonds"
}

for i, cat in ipairs(categories) do
    createToggleButton(cat:gsub("Spawns", ""), scrollingFrame, (i - 1) * 55)
end

-- Minimize button functionality
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    if minimized then
        scrollingFrame:TweenSize(UDim2.new(1, 0, 1, -30), "Out", "Quad", 0.3, true)
        mainFrame.Size = UDim2.new(0, 300, 0, 600)
        minimized = false
    else
        scrollingFrame:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.3, true)
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
        minimized = true
    end
end)

-- Close button functionality
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Blacklists for each category
local blacklists = {}
for _, cat in ipairs(categories) do
    blacklists[cat] = makeBlacklist()
end

-- Main autofarm loop
RunService.Heartbeat:Connect(function()
    if toggles["Shell"].enabled then
        for i=1,150 do
            local spawn = workspace.ItemSpawns.ShellSpawns:FindFirstChild("ShellSpawn"..i)
            if spawn and not blacklists["ShellSpawns"][spawn] then
                blacklists["ShellSpawns"][spawn] = true
                teleportToModel(spawn)
                wait(0.5)
            end
        end
    end
    if toggles["Shushi"].enabled then
        autofarmFolder(workspace.ItemSpawns.ShushiSpawns, "ShushiSpawn", blacklists["ShushiSpawns"])
    end
    if toggles["Taco"].enabled then
        autofarmFolder(workspace.ItemSpawns.TacoSpawns.Folder, "TacoSpawn", blacklists["TacoSpawns"])
    end
    if toggles["Pyramid"].enabled then
        autofarmFolder(workspace.ItemSpawns.PyramidSpawns, "PyramidSpawn", blacklists["PyramidSpawns"])
    end
    if toggles["Pizza"].enabled then
        autofarmFolder(workspace.ItemSpawns.PizzaSpawns, "PizzaSpawn", blacklists["PizzaSpawns"])
    end
    if toggles["Noodle"].enabled then
        autofarmFolder(workspace.ItemSpawns.NoodleSpawns, "NoodleSpawn", blacklists["NoodleSpawns"])
    end
    if toggles["KuwaitTower"].enabled then
        local ktSpawns = workspace.ItemSpawns.KuwaitTowerSpawns
        if ktSpawns:FindFirstChild("KuwaitTowerSpawn") and not blacklists["KuwaitTowerSpawns"][ktSpawns.KuwaitTowerSpawn] then
            blacklists["KuwaitTowerSpawns"][ktSpawns.KuwaitTowerSpawn] = true
            teleportToModel(ktSpawns.KuwaitTowerSpawn)
            wait(0.5)
        end
        for i=1,50 do
            local spawn = ktSpawns:FindFirstChild("KuwaitTowerSpawn"..i)
            if spawn and not blacklists["KuwaitTowerSpawns"][spawn] then
                blacklists["KuwaitTowerSpawns"][spawn] = true
                teleportToModel(spawn)
                wait(0.5)
            end
        end
    end
    if toggles["Goreng"].enabled then
        autofarmFolder(workspace.ItemSpawns.GorengSpawns, "GorengSpawn", blacklists["GorengSpawns"])
    end
    if toggles["Croissant"].enabled then
        autofarmFolder(workspace.ItemSpawns.CroissantSpawns, "CroissantSpawn", blacklists["CroissantSpawns"])
    end
    if toggles["Chest"].enabled then
        autofarmChests(workspace.ItemSpawns.ChestSpawns, blacklists["ChestSpawns"])
    end
    if toggles["Camel"].enabled then
        autofarmFolder(workspace.ItemSpawns.CamelSpawns, "CamleSpawn", blacklists["CamelSpawns"])
    end
    if toggles["Diamonds"].enabled then
        local diamondFolders = {
            workspace.ItemSpawns.DailyDiamond.IndonesiaDiamonds,
            workspace.ItemSpawns.DailyDiamond.ItalyDiamonds,
            workspace.ItemSpawns.DailyDiamond.JapanDiamonds,
            workspace.ItemSpawns.DailyDiamond.KuwaitDiamonds,
            workspace.ItemSpawns.DailyDiamond.MexicoDiamonds,
            workspace.ItemSpawns.DailyDiamond.MrBeastLandDiamonds,
            workspace.ItemSpawns.DailyDiamond.SaudiArabiaDiamonds,
            workspace.ItemSpawns.DailyDiamond.SouthKoreaDiamonds,
            workspace.ItemSpawns.DailyDiamond,
        }
        for _, folder in ipairs(diamondFolders) do
            for i=1,150 do
                local diamond = folder:FindFirstChild("diamond"..i)
                if diamond then
                    teleportToModel(diamond)
                    wait(0.5)
                end
            end
        end
    end
end)
