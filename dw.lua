repeat task.wait() until game:IsLoaded()
-- Initializing
local Driveworld = {}
local material = nil
local lp = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Systems = ReplicatedStorage:WaitForChild("Systems")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DriveworldAutoGUI"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = MainFrame

-- Function to create Toggles
local function createToggle(name, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, -20, 0, 30)
    Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.Font = Enum.Font.SourceSans
    Toggle.TextSize = 18
    Toggle.Text = name .. ": OFF"
    Toggle.Parent = MainFrame

    local state = false
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Function to create Dropdown
local function createDropdown(name, items, callback)
    local Dropdown = Instance.new("TextButton")
    Dropdown.Size = UDim2.new(1, -20, 0, 30)
    Dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    Dropdown.Font = Enum.Font.SourceSans
    Dropdown.TextSize = 18
    Dropdown.Text = name .. ": " .. items[1]
    Dropdown.Parent = MainFrame

    local index = 1
    Dropdown.MouseButton1Click:Connect(function()
        index = index % #items + 1
        Dropdown.Text = name .. ": " .. items[index]
        callback(items[index])
    end)
end

-- Create GUI Elements
createToggle("Auto Delivery Truck", function(state)
    Driveworld["autodelivery"] = state
end)

createToggle("Auto Delivery Material", function(state)
    Driveworld["autodeliverymaterial"] = state
    if not state then
        Systems:WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
        Systems:WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
    end
end)

createToggle("Auto Delivery Food", function(state)
    Driveworld["autodeliveryfood"] = state
end)

createDropdown("Select Material", {"Wood", "Steel"}, function(selected)
    material = selected
end)

-- Auto Delivery Functions
-- This is the main logic for the auto-delivery features

-- Function to get the player's character
local function getCharacter()
    return lp.Character or lp.CharacterAdded:Wait()
end

-- Function to check if the player is in a vehicle
local function isInVehicle()
    for _, v in next, workspace.Cars:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp then
            if v:FindFirstChild("CurrentDriver") and v:FindFirstChild("CurrentDriver").Value == lp then
                return true
            end
        end
    end
    return false
end

-- Function to get the player's vehicle
local function getVehicle()
    for _, v in next, workspace.Cars:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp then
            return v
        end
    end
    return nil
end

-- Function to spawn a vehicle
local function spawnVehicle()
    local Cars = ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(lp.Name):WaitForChild("Inventory"):WaitForChild("Cars")
    local Truck = Cars:FindFirstChild("FullE") or Cars:FindFirstChild("Casper")
    local normalCar = Cars:FindFirstChildWhichIsA("Folder")
    if Truck then
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(Truck)
    else
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(normalCar)
    end
end

-- Auto Delivery Logic (Food Delivery)
task.spawn(function()
    while task.wait(1) do
        if Driveworld["autodeliveryfood"] then
            if not isInVehicle() then
                if not getVehicle() then
                    spawnVehicle()
                end
                getCharacter().HumanoidRootPart.CFrame = getVehicle().PrimaryPart.CFrame
                task.wait(1)
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end
            local completePos
            local completionRegion
            local job = lp.PlayerGui.Score.Frame.Jobs
            repeat task.wait()
                if job.Visible == false then
                    Systems:WaitForChild("Jobs"):WaitForChild("StartJob"):InvokeServer(workspace:WaitForChild("Jobs"):WaitForChild("FoodDelivery"), workspace:WaitForChild("Jobs"):WaitForChild("FoodDelivery"):WaitForChild("StartPoints"):WaitForChild("ClubManta"))
                end
            until job.Visible == true or not Driveworld["autodeliveryfood"]
            repeat task.wait(0.1)
                if workspace:FindFirstChild("CompletionRegion") then
                    completionRegion = workspace:FindFirstChild("CompletionRegion")
                end
            until completionRegion or not Driveworld["autodeliveryfood"]
            if completionRegion then
                completePos = completionRegion:FindFirstChild("Primary").CFrame * CFrame.new(0, 3, 0)
            end
            getVehicle():SetPrimaryPartCFrame(completePos)
            task.wait(0.5)
            Systems:WaitForChild("Jobs"):WaitForChild("CompleteJob"):InvokeServer()
            task.wait(0.5)
            if lp.PlayerGui.JobComplete.Enabled then
                Systems:WaitForChild("Jobs"):WaitForChild("CashBankedEarnings"):FireServer()
                for _, v in next, getconnections(lp.PlayerGui.JobComplete.Window.Content.Buttons.CloseButton.MouseButton1Click) do
                    v:Fire()
                end
            end
        end
    end
end)

-- Auto Delivery Logic (Material Delivery)
task.spawn(function()
    while task.wait(1) do
        if Driveworld["autodeliverymaterial"] and material then
            local cargo
            local completePos
            local completionRegion
            local contracts = lp.PlayerGui.Score.Frame.Contracts
            if not isInVehicle() then
                if not getVehicle() then
                    spawnVehicle()
                end
                getCharacter().HumanoidRootPart.CFrame = getVehicle().PrimaryPart.CFrame
                task.wait(1)
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end
            repeat task.wait(0.1)
                if contracts.Visible == false then
                    Systems:WaitForChild("Contracts"):WaitForChild("PrecalculateRoutes"):InvokeServer()
                    task.wait(0.5)
                    Systems:WaitForChild("Contracts"):WaitForChild("StartContract"):InvokeServer(material)
                end
            until contracts.Visible == true or not Driveworld["autodeliverymaterial"]
            task.wait(1)
            repeat task.wait(0.5)
                for _, v in next, workspace:GetChildren() do
                    if v.Name == "Model" and (v:FindFirstChild("SteelPalettes") or v:FindFirstChild("WoodCrates") or v:FindFirstChild("ShippingCargo")) and v:FindFirstChildWhichIsA("Model").PrimaryPart then
                        cargo = v:FindFirstChildWhichIsA("Model").PrimaryPart
                    end
                end
            until cargo or not Driveworld["autodeliverymaterial"]
            if cargo and getVehicle() and getVehicle().PrimaryPart then
                getVehicle():SetPrimaryPartCFrame(cargo.CFrame)
                task.wait(1)
                if (cargo.Position - getVehicle().PrimaryPart.Position).magnitude <= 30 then
                    VirtualInputManager:SendKeyEvent(true, "E", false, game)
                end
            end
            task.wait(1)
            local count = 0
            repeat task.wait(0.1)
                if workspace:FindFirstChild("CompletionRegion") then
                    completionRegion = workspace.CompletionRegion
                end
                count = count + 1
            until completionRegion or not Driveworld["autodeliverymaterial"] or count >= 50
            if completionRegion then
                completePos = completionRegion:FindFirstChild("Primary").CFrame * CFrame.new(0, 3, 0)
            end
            if completePos then
                getVehicle():SetPrimaryPartCFrame(completePos)
                task.wait(1)
                Systems:WaitForChild("Contracts"):WaitForChild("DropoffCargo"):InvokeServer()
            end
        end
    end
end)
