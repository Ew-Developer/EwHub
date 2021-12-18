if not game:IsLoaded() then game.Loaded:Wait() end task.wait(5)

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = nil

local DefaultTheme = {
    SchemeColor = Color3.fromRGB(35, 175, 100),
    Background = Color3.fromRGB(40, 40, 40),
    Header = Color3.fromRGB(30, 30, 30),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(50, 50, 50)
}
local Theme = {}
for t,c in pairs(DefaultTheme) do
    Theme[t] = c
end

local Teleports = {}

local Games = {
    [155615604] = {"Prison Life",function()
        local Items = {"M9","Remington 870","AK-47","M4A1","Riot Shield"}
        local Guns = {"M9","Remington 870","AK-47","M4A1"}
        local Teams = {"Guard","Inmate","Criminal","Neutral"}

        Teleports = {
            {"Cafeteria",CFrame.new(879,99,2247)};
            {"Kitchen",CFrame.new(912.483459, 99.9899597, 2226.25342)};
            {"Cells",CFrame.new(910,99,2477)};
            {"Yard",CFrame.new(779,99,2477)};
            {"Sewer",CFrame.new(916.682983, 78.7001114, 2429.14038)};
            {"Sewer Exit",CFrame.new(916.427979, 99.1453247, 2104.39771)};
            {"Prison Entrance",CFrame.new(657.258972, 99.9900055, 2272.45728)};
            {"Prison Garage",CFrame.new(616.198975, 98.2000275, 2505.71753)};
            {"Prison Outside",CFrame.new(447.661346, 98.0399399, 2217.46802)};
            {"Prison Back",CFrame.new(797.761169, 98.1900101, 2184.80664)};
            {"Criminal Base",CFrame.new(-888.868408, 94.1270523, 2133.46558)};
            {"Gas Station",CFrame.new(-503.193329, 54.3937874, 1678.29175)};
            {"Armory",CFrame.new(403.913788, 11.8253431, 1164.46436)};
            {"Road Room",CFrame.new(-66.5592117, 10.8399124, 1345.65686)};
            {"Hidden Room",CFrame.new(692.665344, 100.190758, 2344.46704)};
        }

        local AutoReload = false
        local AutoMod = false
        local AutoLoadout = false
        local Godmode = false
        local LockTeam = false

        local CanLoadCharacter = true
        local LastCf = CFrame.new()
        local LastCamCf = CFrame.new()
        local LastTeam = ""
        local CanSetTeam = true

        local function ModItem(v)
            repeat RunService.RenderStepped:Wait() until Player.Character and (Player.Character:FindFirstChild(v) or Player:WaitForChild("Backpack"):FindFirstChild(v))
            if Player.Character:FindFirstChild(v) then
                module = Player.Character:FindFirstChild(v):FindFirstChild("GunStates")
            elseif Player:WaitForChild("Backpack"):FindFirstChild(v) then
                module = Player:WaitForChild("Backpack"):FindFirstChild(v):FindFirstChild("GunStates")
            end

            if module then
                module = require(module)

                module.StoredAmmo = math.huge
                module.FireRate = 0.1
                module.AutoFire = true
                module.Range = math.huge
                module.Spread = 0
                module.ReloadTime = 0
                module.Bullets = 10
            end
        end
        local function Loadout()
            local Backpack = Player:WaitForChild("Backpack")

            for _,v in ipairs(Items) do
                if v ~= "M4A1" and v ~= "Riot Shield" then
                    if Player.Character and not Backpack:FindFirstChild(v) or not Player.Character:FindFirstChild(v) then
                        Workspace:WaitForChild("Remote"):WaitForChild("ItemHandler"):InvokeServer(Workspace:WaitForChild("Prison_ITEMS"):WaitForChild("giver"):WaitForChild(v):WaitForChild("ITEMPICKUP"))
            
                        if AutoMod then
                            ModItem(v)
                        end
                    end
                end
            end
        end
        local function SetTeam(v)
            CanSetTeam = false
            if v == "Criminal" and Player.Character then
                local cf = Player.Character.PrimaryPart.CFrame
                repeat
                    Player.Character:SetPrimaryPartCFrame(CFrame.new(-920.950195, 95.327179, 2131.98975))
                    RunService.RenderStepped:Wait()
                until tostring(Player.TeamColor) == "Really red"
                Player.Character:SetPrimaryPartCFrame(cf)
                CanSetTeam = true
            else
                local Color = nil
                if v == "Guard" then
                    Color = "Bright blue"
                elseif v == "Inmate" then
                    Color = "Bright orange"
                elseif v == "Neutral" then
                    Color = "Medium stone grey"
                end
                
                if Color then
                    Workspace:WaitForChild("Remote"):WaitForChild("TeamEvent"):FireServer(Color)
                    repeat
                        RunService.RenderStepped:Wait()
                    until tostring(Player.TeamColor) == Color
                    CanSetTeam = true
                end
            end
        end
        local function SetupCharacter(Character)
            CanSetTeam = false

            local cf = LastCf
            local ccf = LastCamCf
            repeat RunService.RenderStepped:Wait() until Player.Character and Player.Character.Parent == Workspace
            RunService.RenderStepped:Wait()

            if AutoLoadout then
                Loadout()
            end
            if not CanLoadCharacter and Godmode then
                Player.Character:SetPrimaryPartCFrame(cf)
                Workspace.CurrentCamera.CFrame = ccf
            end
            CanLoadCharacter = false

            local Humanoid = Character:WaitForChild("Humanoid")
            Humanoid.Died:Connect(function()
                if not Godmode then return end

                local cf = Character.PrimaryPart.CFrame
                local ccf = Workspace.CurrentCamera.CFrame
                task.spawn(function()
                    Player.CharacterAdded:Wait()
                    repeat RunService.RenderStepped:Wait() until Player.Character and Player.Character.Parent == Workspace
                    RunService.RenderStepped:Wait()
                    Player.Character:SetPrimaryPartCFrame(cf)
                    Workspace.CurrentCamera.CFrame = ccf
                end)
                CanLoadCharacter = true
                Workspace:WaitForChild("Remote"):WaitForChild("loadchar"):InvokeServer()
            end)

            RunService.RenderStepped:Wait()
            CanSetTeam = true
        end

        do
            local GameTab = Window:NewTab("Game")
            local TeamsTab = Window:NewTab("Teams")
            local ItemsTab = Window:NewTab("Items")

            local GameSettings = GameTab:NewSection("Settings")
            GameSettings:NewToggle("Godmode","Toggles godmode",function(v)
                Godmode = v
            end)

            local TeamSettings = TeamsTab:NewSection("Set team")
            TeamSettings:NewToggle("Lock team","Toggles lock team",function(v)
                LockTeam = v
                if not LockTeam then
                    LastTeam = ""
                end
            end)

            local SetTeamSection = TeamsTab:NewSection("Set team")
            SetTeamSection:NewDropdown("...","Sets your team",Teams,function(v)
                SetTeam(v)
                LastTeam = v
            end)

            local ItemsSettings = ItemsTab:NewSection("Settings")
            ItemsSettings:NewToggle("Auto reload","Toggles auto reload",function(v)
                AutoReload = v
            end)
            ItemsSettings:NewToggle("Auto mod","Toggles auto item mod",function(v)
                AutoMod = v
            end)
            ItemsSettings:NewToggle("Auto loadout","Toggles auto loadout",function(v)
                AutoLoadout = v
            end)

            local GiveItem = ItemsTab:NewSection("Give item")
            GiveItem:NewDropdown("...","Gives you an item",Items,function(v)
                Workspace:WaitForChild("Remote"):WaitForChild("ItemHandler"):InvokeServer(Workspace:WaitForChild("Prison_ITEMS"):WaitForChild("giver"):WaitForChild(v):WaitForChild("ITEMPICKUP"))
            
                if AutoMod then
                    ModItem(v)
                end
            end)

            local ModItem = ItemsTab:NewSection("Mod item")
            ModItem:NewDropdown("...","Mods an item",Guns,function(v)
                local module = nil

                ModItem(v)
            end)
        end

        RunService.RenderStepped:Connect(function()
            pcall(function()
                LastCf = Player.Character.PrimaryPart.CFrame
                LastCamCf = Workspace.CurrentCamera.CFrame
            end)

            if AutoReload then
                local module = nil

                if Player.Character:FindFirstChildOfClass("Tool") then
                    module = Player.Character:FindFirstChildOfClass("Tool"):FindFirstChild("GunStates")
                end

                if module then
                    module = require(module)

                    if module.CurrentAmmo <= 0 then
                        module.CurrentAmmo = module.MaxAmmo
                        ReplicatedStorage:WaitForChild("ReloadEvent"):FireServer(Player.Character:FindFirstChildOfClass("Tool"))
                    end
                end
            end
            if LockTeam and LastTeam ~= "" and CanSetTeam then
                local Color = nil
                if LastTeam == "Guard" then
                    Color = "Bright blue"
                elseif LastTeam == "Inmate" then
                    Color = "Bright orange"
                elseif LastTeam == "Criminal" then
                    Color = "Really red"
                elseif LastTeam == "Neutral" then
                    Color = "Medium stone grey"
                end

                if Color then
                    if tostring(Player.TeamColor) ~= Color then
                        SetTeam(LastTeam)
                    end
                end
            end
        end)
        task.spawn(function()
            while RunService.RenderStepped:Wait() do
                if AutoLoadout then
                    Loadout()
                end
            end
        end)

        Player.CharacterAdded:Connect(SetupCharacter)
        SetupCharacter(Player.Character)
    end}
}

Window = Library.CreateLib("Ew Hub - "..(Games[game.PlaceId] and Games[game.PlaceId][1] or "Unsupported game"),Theme)
if Games[game.PlaceId] then Games[game.PlaceId][2]() end

do
    if #Teleports > 0 then
        local TeleportTab = Window:NewTab("Teleport")

        local Methods = {
            "Instant";
            "Smooth";
        }
        local Method = Methods[1]

        local TeleportMethod = TeleportTab:NewSection("Teleport method")
        TeleportMethod:NewDropdown(Method,"Sets your teleport method",Methods,function(m)
            Method = m
        end)

        local TeleportsSection = TeleportTab:NewSection("Teleports")
        for _,d in ipairs(Teleports) do
            TeleportsSection:NewButton(d[1],"Teleports you to "..string.lower(d[1]),function()
                if Method == "Instant" then
                    Player.Character:SetPrimaryPartCFrame(d[2])
                elseif Method == "Smooth" then
                    TweenService:Create(Player.Character.PrimaryPart,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame = d[2]}):Play()
                end
            end)
        end
    end
end
do
    local MiscTab = Window:NewTab("Misc")

    local Movement = MiscTab:NewSection("Movement")
    Movement:NewSlider("WalkSpeed","Sets your walkspeed",500,16,function(s)
       Player.Character.Humanoid.WalkSpeed = s
    end)
    Movement:NewSlider("JumpPower","Sets your jumppower",500,50,function(p)
        Player.Character.Humanoid.JumpPower = p
    end)
    Movement:NewToggle("Sit","Toggles your sit value",function(v)
        Player.Character.Humanoid.Sit = v
    end)
    Movement:NewToggle("PlatformStand","Toggles your platformstand value",function(v)
        Player.Character.Humanoid.PlatformStand = v
    end)
end
do
    local GamesTab = Window:NewTab("Games")

    local Teleport = GamesTab:NewSection("Teleport")
    _G.EwHubTelepoting = false
    for id,d in pairs(Games) do
        Teleport:NewButton(d[1]..(id == game.PlaceId and " (CURRENT)" or ""),"Teleports you to "..d[1],function(color3)
            if _G.EwHubTelepoting then return end
            _G.EwHubTelepoting = true

            xpcall(function()
                local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
                if queueteleport then
                    queueteleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Ew-Developer/EwHub/main/main.lua"))()]])
                end
                game:GetService("TeleportService"):Teleport(id,Player)
            end,function()
                _G.EwHubTelepoting = false
            end)
        end)
    end
end
do
    local CustomizationTab = Window:NewTab("Customization")

    local Customization = CustomizationTab:NewSection("Customization")
    for t,c in pairs(Theme) do
        Customization:NewColorPicker(t,"Changes your "..t,c,function(color3)
            Theme[t] = color3
            Library:ChangeColor(t,color3)
        end)
    end
    Customization:NewButton("Reset theme","Sets your theme to the default theme",function()
        for t,c in pairs(DefaultTheme) do
            Theme[t] = c
            Library:ChangeColor(t,c)
        end
    end)
end
