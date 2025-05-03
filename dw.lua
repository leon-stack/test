repeat task.wait() until game:IsLoaded()
-- Initialisierung
local Driveworld = {}
local material = nil
local lp = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Systems = ReplicatedStorage:WaitForChild("Systems")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Simuliere die Eingabe eines Tastendrucks
local function simulateKeyPress(key)
    local input = Instance.new("InputObject")
    input.KeyCode = Enum.KeyCode[key]
    UserInputService.InputBegan:Fire(input, false)
    UserInputService.InputEnded:Fire(input, false)
end

-- GUI-Erstellung
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

-- Funktion zum Erstellen von Toggles
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

-- Funktion zum Erstellen eines Dropdown-Menüs
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

-- Erstellen der GUI-Elemente
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





-- Initial Setup
local oldnamecall
oldnamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and method == "InvokeServer" and self.Name == "QuitJob" then
        if (Driveworld["autodeliveryfood"] or Driveworld["autodelivery"]) then
            return wait(9e9)
        end
    end
    return oldnamecall(self, ...)
end))

local function getchar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function isvehicle()
    for i, v in next, workspace.Cars:GetChildren() do
        if (v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp) then
            if v:FindFirstChild("CurrentDriver") and v:FindFirstChild("CurrentDriver").Value == lp then
                return true
            end
        end
    end
    return false
end

local function getvehicle()
    for i, v in next, workspace.Cars:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp then
            if v.PrimaryPart then
                return v
            else
                warn("Vehicle missing PrimaryPart!")
            end
        end
    end
    return nil
end

local function spawnvehicle()
    local PlayerData = ReplicatedStorage:FindFirstChild("PlayerData")
    if PlayerData then
        local Cars = PlayerData:WaitForChild(lp.Name):WaitForChild("Inventory"):WaitForChild("Cars")
        local Truck = Cars:FindFirstChild("FullE") or Cars:FindFirstChild("Casper")
        local normalcar = Cars:FindFirstChildWhichIsA("Folder")
        if Truck then
            Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(Truck)
        else
            Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(normalcar)
        end
    else
        warn("PlayerData not found in ReplicatedStorage!")
    end
end

-- Main GUI Controls
Main:Toggle({
    Name = "Auto Delivery Truck",
    StartingState = false,
    Description = "Use Full-E or Casper for more money (works in USA map only). Wait for 40 sec.",
    Callback = function(state)
        Driveworld["autodelivery"] = state
    end
})

Main:Dropdown{
    Name = "Select Material",
    StartingText = "Select...",
    Description = nil,
    Items = {"Wood", "Steel"},
    Callback = function(item)
        material = item
    end
}

Main:Toggle({
    Name = "Auto Delivery Material",
    StartingState = false,
    Description = "Wait 25 sec",
    Callback = function(state)
        Driveworld["autodeliverymaterial"] = state
        if state == false then
            ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
            ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
        end
    end
})

Main:Toggle({
    Name = "Auto Delivery Food",
    StartingState = false,
    Description = "Wait for 20 sec",
    Callback = function(state)
        Driveworld["autodeliveryfood"] = state
    end
})

-- Auto Delivery Loops
task.spawn(function()
    while task.wait() do
        if Driveworld["autodeliveryfood"] then
            if isvehicle() == false then
                if not getvehicle() then
                    spawnvehicle()
                end
                getchar().HumanoidRootPart.CFrame = getvehicle().PrimaryPart.CFrame
                task.wait(1)
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end
            local completepos
            local CompletionRegion
            local job = lp.PlayerGui.Score.Frame.Jobs
            repeat task.wait()
                if job.Visible == false then
                    Systems:WaitForChild("Jobs"):WaitForChild("StartJob"):InvokeServer(workspace:WaitForChild("Jobs"):WaitForChild("FoodDelivery"), workspace:WaitForChild("Jobs"):WaitForChild("FoodDelivery"):WaitForChild("StartPoints"):WaitForChild("ClubManta"))
                end
            until job.Visible == true or Driveworld["autodeliveryfood"] == false
            repeat task.wait(.1)
                if workspace:FindFirstChild("CompletionRegion") then
                    CompletionRegion = workspace:FindFirstChild("CompletionRegion")
                end
            until CompletionRegion or Driveworld["autodeliveryfood"] == false
            for i = 1, 20 do
                if not Driveworld["autodeliveryfood"] or not getvehicle() or not getchar() or isvehicle() == false or job.Visible == false then
                    break
                end
                task.wait(1)
            end
            if CompletionRegion:FindFirstChild("Primary").CFrame then
                completepos = CompletionRegion:FindFirstChild("Primary").CFrame * CFrame.new(0, 3, 0)
            end
            getvehicle():SetPrimaryPartCFrame(completepos)
            task.wait(.5)
            Systems:WaitForChild("Jobs"):WaitForChild("CompleteJob"):InvokeServer()
            task.wait(.5)
            if lp.PlayerGui.JobComplete.Enabled == true then
                Systems:WaitForChild("Jobs"):WaitForChild("CashBankedEarnings"):FireServer()
                for i, v in next, getconnections(lp.PlayerGui.JobComplete.Window.Content.Buttons.CloseButton.MouseButton1Click) do
                    v:Fire()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(.1) do
        if Driveworld["autodelivery"] then
            local job = lp.PlayerGui.Score.Frame.Jobs
            local jobDistance
            local function getjobdistance(Completedistance)
                local jobDist
                local yeas = string.split(Completedistance, " ")
                for i, v in next, yeas do
                    if tonumber(v) then
                        jobDist = v
                        print("Truck Job Distance: " .. jobDist)
                    end
                end
                return jobDist
            end
            if isvehicle() == false then
                if not getvehicle() then
                    spawnvehicle()
                end
                getchar().HumanoidRootPart.CFrame = getvehicle().PrimaryPart.CFrame
                task.wait(1)
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end
            repeat task.wait(.1)
                if job.Visible == false then
                    ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Jobs"):WaitForChild("StartJob"):InvokeServer(workspace:WaitForChild("Jobs"):WaitForChild("Trucking"), workspace:WaitForChild("Jobs"):WaitForChild("Trucking"):WaitForChild("StartPoints"):WaitForChild("Logs"))
                end
            until job.Visible == true or Driveworld["autodelivery"] == false
            print("Start Job")
            repeat task.wait(.1)
                if workspace:FindFirstChild("CompletionRegion") then
                    jobDistance = getjobdistance(workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary"):FindFirstChild("DestinationIndicator"):FindFirstChild("Distance").Text)
                end
                if jobDistance and tonumber(jobDistance) < 2.1 then
                    ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Jobs"):WaitForChild("StartJob"):InvokeServer(workspace:WaitForChild("Jobs"):WaitForChild("Trucking"), workspace:WaitForChild("Jobs"):WaitForChild("Trucking"):WaitForChild("StartPoints"):WaitForChild("Logs"))
                end
            until jobDistance and tonumber(jobDistance) >= 2.1 or Driveworld["autodelivery"] == false
            for i = 1, 40 do
                if not Driveworld["autodelivery"] or not getvehicle() or not getchar() or isvehicle() == false or job.Visible == false then
                    break
                end
                task.wait(1)
            end
            if workspace:FindFirstChild("CompletionRegion") and workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary") then
                getvehicle():SetPrimaryPartCFrame(workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary").CFrame * CFrame.new(0, 3, 0))
            end
            task.wait(.5)
            Systems:WaitForChild("Jobs"):WaitForChild("CompleteJob"):InvokeServer()
            task.wait(.5)
            if lp.PlayerGui.JobComplete.Enabled == true then
                Systems:WaitForChild("Jobs"):WaitForChild("CashBankedEarnings"):FireServer()
                for i, v in next, getconnections(lp.PlayerGui.JobComplete.Window.Content.Buttons.CloseButton.MouseButton1Click) do
                    v:Fire()
                end
            end
            print("Completed Job")
        end
    end
end)

task.spawn(function()
    while task.wait(.1) do
        if Driveworld["autodeliverymaterial"] and material then
            local cargo
            local completepos
            local CompletionRegion
            local Contracts = lp.PlayerGui.Score.Frame.Contracts
            if isvehicle() == false then
                if not getvehicle() then
                    spawnvehicle()
                end
                getchar().HumanoidRootPart.CFrame = getvehicle().PrimaryPart.CFrame
                task.wait(1)
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end
            repeat task.wait(.1)
                if Contracts.Visible == false then
                    ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("PrecalculateRoutes"):InvokeServer()
                    task.wait(.5)        
                    ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("StartContract"):InvokeServer(material)
                end
            until Contracts.Visible == true or Driveworld["autodeliverymaterial"] == false
            task.wait(1)
            repeat task.wait(.5)
                for i, v in next, workspace:GetChildren() do
                    if v.Name == "Model" and (v:FindFirstChild("SteelPalettes") or v:FindFirstChild("WoodCrates") or v:FindFirstChild("ShippingCargo")) and v:FindFirstChildWhichIsA("Model").PrimaryPart then
                        cargo = v:FindFirstChildWhichIsA("Model").PrimaryPart
                    end
                end
            until cargo or Driveworld["autodeliverymaterial"] == false
            if lp.PlayerGui.GarageContracts.Frame.ContractFinished.Visible == true then
                for i, v in next, getconnections(lp.PlayerGui.GarageContracts.Frame.Header.CloseButton.MouseButton1Click) do
                    v:Fire()
                end
            end
            if lp.PlayerGui.CancelActivityConfirmation.Enabled == true then
                for i, v in next, getconnections(lp.PlayerGui.CancelActivityConfirmation.Window.Content.Buttons.Cancel.MouseButton1Click) do
                    v:Fire()
                end
            end
            if cargo and getvehicle() and getvehicle().PrimaryPart then
                getvehicle():SetPrimaryPartCFrame(cargo.CFrame + Vector3.new(0, 3, 0))
                task.wait(1)
                ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("PlaceCargo"):InvokeServer(material)
            end
            task.wait(2)
            if workspace:FindFirstChild("CompletionRegion") then
                completepos = workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary").CFrame * CFrame.new(0, 3, 0)
                getvehicle():SetPrimaryPartCFrame(completepos)
            end
            Systems:WaitForChild("Contracts"):WaitForChild("CompleteContract"):InvokeServer()
            task.wait(.5)
            if lp.PlayerGui.ContractComplete.Enabled == true then
                Systems:WaitForChild("Contracts"):WaitForChild("CashBankedEarnings"):FireServer()
                for i, v in next, getconnections(lp.PlayerGui.ContractComplete.Window.Content.Buttons.CloseButton.MouseButton1Click) do
                    v:Fire()
                end
            end
        end
    end
end)
