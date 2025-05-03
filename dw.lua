repeat task.wait() until game:IsLoaded()
--// GUI-Erstellung
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DriveworldAutoGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Position = UDim2.new(0, 10, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true -- <-- Aktiviert das Draggen

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
    toggle.AutoButtonColor = false
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
    dropdown.AutoButtonColor = false

    dropdown.MouseButton1Click:Connect(function()
        local listStr = name .. " Options:\n"
        for i, item in pairs(items) do
            listStr = listStr .. "[" .. i .. "] " .. item .. "\n"
        end
        print(listStr)
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
    for i,v in next, workspace.Cars:GetChildren() do
        if (v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp) then
            if v:FindFirstChild("CurrentDriver") and v:FindFirstChild("CurrentDriver").Value == lp then
                return true
            end
        end
    end
    return false
end

local function getvehicle()
    for i,v in next, workspace.Cars:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == lp then
            return v
        end
    end
    return
end

local function spawnvehicle()
    local Cars = ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(lp.Name):WaitForChild("Inventory"):WaitForChild("Cars")
    local Truck = Cars:FindFirstChild("FullE") or Cars:FindFirstChild("Casper")
    local normalcar = Cars:FindFirstChildWhichIsA("Folder")
    if Truck then
        Systems:WaitForChild("CarInteraction"):WaitForChild("SpawnPlayerCar"):InvokeServer(Truck)
    else
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
    Description = nil,
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
            ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
            ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("EndContract"):InvokeServer()
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
                completepos = CompletionRegion:FindFirstChild("Primary").CFrame * CFrame.new(0,3,0)
            end
            getvehicle():SetPrimaryPartCFrame(completepos)
            task.wait(.5)
            Systems:WaitForChild("Jobs"):WaitForChild("CompleteJob"):InvokeServer()
            task.wait(.5)
            if lp.PlayerGui.JobComplete.Enabled == true then
                Systems:WaitForChild("Jobs"):WaitForChild("CashBankedEarnings"):FireServer()
                for i,v in next, getconnections(lp.PlayerGui.JobComplete.Window.Content.Buttons.CloseButton.MouseButton1Click) do
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
                for i,v in next, yeas do
                    if tonumber(v) then
                        jobDist = v
                        print("Truck Job Distance : " .. jobDist)
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
                    ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Jobs"):WaitForChild("StartJob"):InvokeServer(workspace:WaitForChild("Jobs"):WaitForChild("Trucking"),workspace:WaitForChild("Jobs"):WaitForChild("Trucking"):WaitForChild("StartPoints"):WaitForChild("Logs"))
                end
            until job.Visible == true or Driveworld["autodelivery"] == false
            print("Start Job")
            repeat task.wait(.1)
                if workspace:FindFirstChild("CompletionRegion") then
                    jobDistance = getjobdistance(workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary"):FindFirstChild("DestinationIndicator"):FindFirstChild("Distance").Text)
                end
                if jobDistance and tonumber(jobDistance) < 2.1 then
                    ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Jobs"):WaitForChild("StartJob"):InvokeServer(workspace:WaitForChild("Jobs"):WaitForChild("Trucking"),workspace:WaitForChild("Jobs"):WaitForChild("Trucking"):WaitForChild("StartPoints"):WaitForChild("Logs"))
                end
            until jobDistance and tonumber(jobDistance) >= 2.1 or Driveworld["autodelivery"] == false
            for i = 1, 40 do
                if not Driveworld["autodelivery"] or not getvehicle() or not getchar() or isvehicle() == false or job.Visible == false then
                    break
                end
                task.wait(1)
            end
            if workspace:FindFirstChild("CompletionRegion") and workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary") then
                getvehicle():SetPrimaryPartCFrame(workspace:FindFirstChild("CompletionRegion"):FindFirstChild("Primary").CFrame * CFrame.new(0,3,0))
            end
            task.wait(.5)
            Systems:WaitForChild("Jobs"):WaitForChild("CompleteJob"):InvokeServer()
            task.wait(.5)
            if lp.PlayerGui.JobComplete.Enabled == true then
                Systems:WaitForChild("Jobs"):WaitForChild("CashBankedEarnings"):FireServer()
                for i,v in next, getconnections(lp.PlayerGui.JobComplete.Window.Content.Buttons.CloseButton.MouseButton1Click) do
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
                for i,v in next, workspace:GetChildren() do
                    if v.Name == "Model" and (v:FindFirstChild("SteelPalettes") or v:FindFirstChild("WoodCrates") or v:FindFirstChild("ShippingCargo")) and v:FindFirstChildWhichIsA("Model").PrimaryPart then
                        cargo = v:FindFirstChildWhichIsA("Model").PrimaryPart
                    end
                end
            until cargo or Driveworld["autodeliverymaterial"] == false
            if lp.PlayerGui.GarageContracts.Frame.ContractFinished.Visible == true then
                for i,v in next, getconnections(lp.PlayerGui.GarageContracts.Frame.Header.CloseButton.MouseButton1Click) do
                    v:Fire()
                end
            end
            if lp.PlayerGui.CancelActivityConfirmation.Enabled == true then
                for i,v in next, getconnections(lp.PlayerGui.CancelActivityConfirmation.Window.Content.Buttons.Cancel.MouseButton1Click) do
                    v:Fire()
                end
            end
            if cargo and getvehicle() and getvehicle().PrimaryPart then
                getvehicle():SetPrimaryPartCFrame(cargo.CFrame)
                task.wait(1)
                if (cargo.Position - getvehicle().PrimaryPart.Position).magnitude <= 30 then
                    VirtualInputManager:SendKeyEvent(true, "E", false, game)
                end
            end
            task.wait(1)
            if lp.PlayerGui.CancelActivityConfirmation.Enabled == true then
                for i,v in next, getconnections(lp.PlayerGui.CancelActivityConfirmation.Window.Content.Buttons.Cancel.MouseButton1Click) do
                    v:Fire()
                end
            end
            local count = 0
            repeat task.wait(.1)
                if workspace:FindFirstChild("CompletionRegion") then
                    CompletionRegion = workspace.CompletionRegion
                end
                count = count + 1
            until CompletionRegion or Driveworld["autodeliverymaterial"] == false or count >= 50
            if CompletionRegion and CompletionRegion:FindFirstChild("Primary").CFrame then
                completepos = CompletionRegion:FindFirstChild("Primary").CFrame * CFrame.new(0,3,0)
            end
            for i = 1, 27 do
                if not Driveworld["autodeliverymaterial"] or not getvehicle() or not getchar() or isvehicle() == false or Contracts.Visible == false then
                    break
                end
                task.wait(1)
            end
            if completepos then
                getvehicle():SetPrimaryPartCFrame(completepos)
                task.wait(1)
                ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Contracts"):WaitForChild("DropoffCargo"):InvokeServer()
            end
        end
    end
end)