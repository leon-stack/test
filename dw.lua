repeat task.wait() until game:IsLoaded()
-- Initializing the GUI
local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Systems = ReplicatedStorage:WaitForChild("Systems")
local lp = game.Players.LocalPlayer
local Driveworld = {}

-- Create the GUI elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 300)
Main.Position = UDim2.new(0.5, -200, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Main.BackgroundTransparency = 0.5
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Auto Delivery System"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.BackgroundTransparency = 1
Title.Parent = Main

-- Add Toggle for Auto Delivery Truck
local AutoDeliveryTruckToggle = Instance.new("TextButton")
AutoDeliveryTruckToggle.Size = UDim2.new(0, 200, 0, 40)
AutoDeliveryTruckToggle.Position = UDim2.new(0.5, -100, 0.2, 0)
AutoDeliveryTruckToggle.Text = "Auto Delivery Truck"
AutoDeliveryTruckToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AutoDeliveryTruckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoDeliveryTruckToggle.Parent = Main

-- Add Dropdown for Selecting Material
local MaterialDropdown = Instance.new("TextButton")
MaterialDropdown.Size = UDim2.new(0, 200, 0, 40)
MaterialDropdown.Position = UDim2.new(0.5, -100, 0.35, 0)
MaterialDropdown.Text = "Select Material"
MaterialDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MaterialDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
MaterialDropdown.Parent = Main

-- Add Toggle for Auto Delivery Material
local AutoDeliveryMaterialToggle = Instance.new("TextButton")
AutoDeliveryMaterialToggle.Size = UDim2.new(0, 200, 0, 40)
AutoDeliveryMaterialToggle.Position = UDim2.new(0.5, -100, 0.5, 0)
AutoDeliveryMaterialToggle.Text = "Auto Delivery Material"
AutoDeliveryMaterialToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AutoDeliveryMaterialToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoDeliveryMaterialToggle.Parent = Main

-- Add Toggle for Auto Delivery Food
local AutoDeliveryFoodToggle = Instance.new("TextButton")
AutoDeliveryFoodToggle.Size = UDim2.new(0, 200, 0, 40)
AutoDeliveryFoodToggle.Position = UDim2.new(0.5, -100, 0.65, 0)
AutoDeliveryFoodToggle.Text = "Auto Delivery Food"
AutoDeliveryFoodToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AutoDeliveryFoodToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoDeliveryFoodToggle.Parent = Main

-- Make the GUI draggable
local dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragInput:Disconnect()
            end
        end)
    end
end)

-- Handle Toggle for Auto Delivery Truck
AutoDeliveryTruckToggle.MouseButton1Click:Connect(function()
    Driveworld["autodelivery"] = not Driveworld["autodelivery"]
    print("Auto Delivery Truck:", Driveworld["autodelivery"])
end)

-- Handle Dropdown for Material Selection
MaterialDropdown.MouseButton1Click:Connect(function()
    local materials = {"Wood", "Steel"}
    local selectedMaterial = materials[math.random(1, #materials)]
    print("Selected Material:", selectedMaterial)
end)

-- Handle Toggle for Auto Delivery Material
AutoDeliveryMaterialToggle.MouseButton1Click:Connect(function()
    Driveworld["autodeliverymaterial"] = not Driveworld["autodeliverymaterial"]
    print("Auto Delivery Material:", Driveworld["autodeliverymaterial"])
end)

-- Handle Toggle for Auto Delivery Food
AutoDeliveryFoodToggle.MouseButton1Click:Connect(function()
    Driveworld["autodeliveryfood"] = not Driveworld["autodeliveryfood"]
    print("Auto Delivery Food:", Driveworld["autodeliveryfood"])
end)

-- Function to spawn a vehicle
local function spawnVehicle()
    local Cars = ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(lp.Name):WaitForChild("Inventory"):WaitForChild("Cars")
    local Truck = Cars:FindFirstChild("FullE") or Cars:FindFirstChild("Casper")
    local normalcar = Cars:FindFirstChildWhichIsA("Folder")
    if Truck then
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(Truck)
    else
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(normalcar)
    end
end

-- Check if player has a vehicle
local function isVehicle()
    for i, v in next, workspace.Cars:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp then
            if v:FindFirstChild("CurrentDriver") and v:FindFirstChild("CurrentDriver").Value == lp then
                return true
            end
        end
    end
    return false
end

-- Main Loop for Auto Delivery
task.spawn(function()
    while task.wait() do
        if Driveworld["autodeliveryfood"] then
            if isVehicle() == false then
                spawnVehicle()
            end
            -- Continue with your Auto Delivery Food Logic
            print("Auto Delivery Food logic running...")
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Driveworld["autodelivery"] then
            if isVehicle() == false then
                spawnVehicle()
            end
            -- Continue with your Auto Delivery Truck Logic
            print("Auto Delivery Truck logic running...")
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if Driveworld["autodeliverymaterial"] then
            if isVehicle() == false then
                spawnVehicle()
            end
            -- Continue with your Auto Delivery Material Logic
            print("Auto Delivery Material logic running...")
        end
    end
end)