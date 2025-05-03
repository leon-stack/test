repeat task.wait() until game:IsLoaded()

--// GUI-Erstellung
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DriveworldAutoGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Position = UDim2.new(0, 10, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function createToggle(name, callback)
    local toggle = Instance.new("TextButton", Frame)
    toggle.Size = UDim2.new(0, 230, 0, 30)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Text = name .. ": OFF"
    toggle.Font = Enum.Font.SourceSans
    toggle.TextSize = 18
    local active = false
    toggle.MouseButton1Click:Connect(function()
        active = not active
        toggle.Text = name .. ": " .. (active and "ON" or "OFF")
        callback(active)
    end)
end

local function createDropdown(name, items, callback)
    local dropdown = Instance.new("TextButton", Frame)
    dropdown.Size = UDim2.new(0, 230, 0, 30)
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Text = name .. ": Select..."
    dropdown.Font = Enum.Font.SourceSans
    dropdown.TextSize = 18

    dropdown.MouseButton1Click:Connect(function()
        local listStr = "Choose: "
        for i, item in pairs(items) do
            listStr = listStr .. "\n[" .. i .. "] " .. item
        end
        local chosen = tonumber(string.match(tostring(rconsoleinput and rconsoleinput() or "1"), "%d+"))
        if items[chosen] then
            dropdown.Text = name .. ": " .. items[chosen]
            callback(items[chosen])
        end
    end)
end

--// Globale Variablen
local lp = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Systems = ReplicatedStorage:WaitForChild("Systems")
local Driveworld = {}

local material

--// GUI Elemente
createToggle("Auto Delivery Truck", function(state)
    Driveworld["autodelivery"] = state
end)

createDropdown("Select Material", {"Wood", "Steel"}, function(item)
    material = item
end)

createToggle("Auto Delivery Material", function(state)
    Driveworld["autodeliverymaterial"] = state
    if not state then
        ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
        ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
    end
end)

createToggle("Auto Delivery Food", function(state)
    Driveworld["autodeliveryfood"] = state
end)