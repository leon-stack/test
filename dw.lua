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

local lp = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Systems = ReplicatedStorage:WaitForChild("Systems")  -- Make sure the Systems service exists
local VirtualInputManager = game:GetService("VirtualInputManager")

local function getchar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function isvehicle()
    for _, v in next, workspace.Cars:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v.Owner.Value == lp then
            if v:FindFirstChild("CurrentDriver") and v.CurrentDriver.Value == lp then
                return true
            end
        end
    end
    return false
end

local function getvehicle()
    for _, v in next, workspace.Cars:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v.Owner.Value == lp then
            if v:FindFirstChild("CurrentDriver") and v.CurrentDriver.Value == lp then
                -- Ensure the vehicle has a PrimaryPart
                if v.PrimaryPart then
                    return v
                else
                    warn("Vehicle missing PrimaryPart!")
                end
            end
        end
    end
    return nil
end

local function spawnvehicle()
    local Cars = ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(lp.Name):WaitForChild("Inventory"):WaitForChild("Cars")
    local Truck = Cars:FindFirstChild("FullE") or Cars:FindFirstChild("Casper")
    local normalcar = Cars:FindFirstChildWhichIsA("Folder")
    
    if Truck then
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(Truck)
    elseif normalcar then
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(normalcar)
    end
end

Main:Toggle({
    Name = "Auto Delivery Truck",
    StartingState = false,
    Description = "Use Full-E or Casper for more money(work in USA map only) wait for 40 sec",
    Callback = function(state)
        Driveworld["autodelivery"] = state
    end
})

Main:Dropdown{
    Name = "Select Material",
    StartingText = "Select...",
    Items = {"Wood", "Steel"},
    Callback = function(item)
        material = item
    end
}

Main:Toggle({
    Name = "Auto Delivery Material",
    StartingState = false,
    Description = "wait 25 sec",
    Callback = function(state)
        Driveworld["autodeliverymaterial"] = state
        if state == false then
            Systems:WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
            Systems:WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
        end
    end
})

Main:Toggle({
    Name = "Auto Delivery Food",
    StartingState = false,
    Description = "wait for 20 sec",
    Callback = function(state)
        Driveworld["autodeliveryfood"] = state
    end
})

task.spawn(function()
    while task.wait() do
        if Driveworld["autodeliveryfood"] then
            if not isvehicle() then
                if not getvehicle() then
                    spawnvehicle()
                end
                getchar().HumanoidRootPart.CFrame = getvehicle().PrimaryPart.CFrame
                task.wait(1)
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end
            
            -- Add necessary job handling logic based on your game's job system
            local completepos
            local CompletionRegion
            local jobComplete = lp.PlayerGui:FindFirstChild("JobComplete")
if jobComplete then
    if jobComplete.Enabled then
        Systems:WaitForChild("Jobs"):WaitForChild("CashBankedEarnings"):FireServer()
        for _, v in next, getconnections(jobComplete.Window.Content.Buttons.CloseButton.MouseButton1Click) do
            v:Fire()
        end
    end
else
    warn("JobComplete UI not found!")
end

            until job.Visible == true or Driveworld["autodeliveryfood"] == false
            repeat task.wait(.1)
                if workspace:FindFirstChild("CompletionRegion") then
                    CompletionRegion = workspace:FindFirstChild("CompletionRegion")
                end
            until CompletionRegion or Driveworld["autodeliveryfood"] == false
            
            -- Complete the job logic
            if CompletionRegion then
                completepos = CompletionRegion:FindFirstChild("Primary").CFrame * CFrame.new(0, 3, 0)
                getvehicle():SetPrimaryPartCFrame(completepos)
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
    end
end)