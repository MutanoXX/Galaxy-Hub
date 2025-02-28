-- Galaxy Hub Universal V5 Premium
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostQut/FreerainUI/main/source.lua"))()

-- Configuração da Interface
local WindowConfig = {
    Name = "Galaxy Hub Premium",
    BackgroundImage = "https://i.imgur.com/IzutOkh.jpeg",
    BackgroundColor = Color3.fromRGB(20, 20, 30),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(0, 170, 255),
    Size = UDim2.new(0, 600, 0, 400),
    Position = UDim2.new(0.5, -300, 0.5, -200),
    BorderSizePixel = 0,
    Draggable = true
}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

-- Variáveis Globais
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configurações Globais
_G.Settings = {
    Player = {
        WalkSpeed = 16,
        JumpPower = 50,
        HipHeight = 0,
        Gravity = 196.2,
        NoClip = false,
        InfiniteJump = false,
        AutoSprint = false,
        BunnyHop = false,
        FlySpeed = 50,
        Flying = false
    },
    Combat = {
        KillAura = false,
        KillAuraRange = 15,
        AutoParry = false,
        HitboxExpander = false,
        HitboxSize = 5,
        GodMode = false,
        AntiRagdoll = false
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        Smoothness = 0.5,
        FOV = 400,
        ShowFOV = true,
        TargetPart = "Head",
        PredictionEnabled = true,
        PredictionAmount = 0.165,
        AutoShoot = false,
        TriggerBot = false,
        SilentAim = false
    },
    AimLock = {
        Enabled = false,
        Smoothness = 0.5,
        HeadLock = true,
        AutoShoot = false,
        TriggerKey = Enum.KeyCode.X,
        Prediction = true,
        PredictionAmount = 0.165
    },
    Visuals = {
        ESP = false,
        ESPBoxes = false,
        ESPNames = false,
        ESPTracers = false,
        ESPTeamColor = false,
        Chams = false,
        FullBright = false,
        NoFog = false,
        Crosshair = false,
        CustomSky = false
    },
    World = {
        NoClip = false,
        AutoFarm = false,
        CollectAura = false,
        CollectRange = 15,
        AutoCollect = false
    },
    Protection = {
        AntiKick = true,
        AntiTeleport = true,
        AntiBan = true,
        AntiCheatBypass = true,
        AntiSpeedCheck = true,
        AntiJumpCheck = true
    }
}

-- Criação da Interface
local Window = Library.CreateWindow(WindowConfig)

-- Tabs
local MovementTab = Window:AddTab("Movimento")
local CombatTab = Window:AddTab("Combate")
local AimbotTab = Window:AddTab("Aimbot")
local VisualsTab = Window:AddTab("Visuais")
local WorldTab = Window:AddTab("Mundo")
local SettingsTab = Window:AddTab("Configurações")

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = _G.Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Crosshair
local CrosshairParts = {
    Top = Drawing.new("Line"),
    Bottom = Drawing.new("Line"),
    Left = Drawing.new("Line"),
    Right = Drawing.new("Line")
}

for _, part in pairs(CrosshairParts) do
    part.Visible = false
    part.Thickness = 1
    part.Color = Color3.fromRGB(255, 255, 255)
end

-- Funções Utilitárias
local function IsAlive(player)
    return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function GetClosestPlayer()
    local MaxDist = _G.Settings.Aimbot.FOV
    local Target = nil
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and IsAlive(v) then
            if _G.Settings.Aimbot.TeamCheck and v.Team == Player.Team then continue end
            
            local TargetPart = v.Character:FindFirstChild(_G.Settings.Aimbot.TargetPart)
            if not TargetPart then continue end
            
            -- Wall Check
            if _G.Settings.Aimbot.WallCheck then
                local Ray = Ray.new(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 2000)
                local Hit, _ = workspace:FindPartOnRayWithIgnoreList(Ray, {Player.Character, v.Character})
                if Hit then continue end
            end
            
            local TargetPos = TargetPart.Position
            if _G.Settings.Aimbot.PredictionEnabled then
                TargetPos = TargetPos + (v.Character.HumanoidRootPart.Velocity * _G.Settings.Aimbot.PredictionAmount)
            end
            
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(TargetPos)
            if not OnScreen then continue end
            
            local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            if Distance < MaxDist then
                MaxDist = Distance
                Target = v
            end
        end
    end
    return Target
end

-- Sistema de Movimento
local MovementSystem = {
    EnableFly = function()
        local FlyPart = Instance.new("BodyVelocity")
        FlyPart.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        FlyPart.Velocity = Vector3.new(0, 0, 0)
        FlyPart.Parent = HumanoidRootPart
        
        RunService.RenderStepped:Connect(function()
            if _G.Settings.Player.Flying then
                local Forward = Camera.CFrame.LookVector
                local Right = Camera.CFrame.RightVector
                local Up = Camera.CFrame.UpVector
                
                local Movement = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    Movement = Movement + Forward
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    Movement = Movement - Forward
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    Movement = Movement + Right
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    Movement = Movement - Right
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    Movement = Movement + Up
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    Movement = Movement - Up
                end
                
                FlyPart.Velocity = Movement.Unit * _G.Settings.Player.FlySpeed
            else
                FlyPart:Destroy()
            end
        end)
    end,
    
    EnableBHop = function()
        RunService.Heartbeat:Connect(function()
            if _G.Settings.Player.BunnyHop and Humanoid.MoveDirection.Magnitude > 0 then
                if Humanoid:GetState() == Enum.HumanoidStateType.Running then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
}

-- Sistema de Combate
local CombatSystem = {
    KillAura = function()
        RunService.Heartbeat:Connect(function()
            if _G.Settings.Combat.KillAura then
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= Player and IsAlive(v) then
                        local Distance = (HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                        if Distance <= _G.Settings.Combat.KillAuraRange then
                            local Args = {
                                [1] = v.Character.Humanoid,
                                [2] = {
                                    ["Force"] = Vector3.new(0, 0, 0),
                                    ["Type"] = Enum.HumanoidStateType.Dead
                                }
                            }
                            game.ReplicatedStorage.RemoteEvent:FireServer(unpack(Args))
                        end
                    end
                end
            end
        end)
    end,
    
    HitboxExpander = function()
        RunService.RenderStepped:Connect(function()
            if _G.Settings.Combat.HitboxExpander then
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= Player and IsAlive(v) then
                        v.Character.HumanoidRootPart.Size = Vector3.new(
                            _G.Settings.Combat.HitboxSize,
                            _G.Settings.Combat.HitboxSize,
                            _G.Settings.Combat.HitboxSize
                        )
                        v.Character.HumanoidRootPart.Transparency = 0.8
                    end
                end
            end
        end)
    end
}

-- Sistema Visual
local VisualSystem = {
    ESP = {
        Boxes = {},
        Names = {},
        Tracers = {},
        
        CreateESP = function(player)
            local Box = Drawing.new("Square")
            Box.Visible = false
            Box.Color = Color3.fromRGB(255, 255, 255)
            Box.Thickness = 1
            Box.Transparency = 1
            Box.Filled = false
            
            local Name = Drawing.new("Text")
            Name.Visible = false
            Name.Color = Color3.fromRGB(255, 255, 255)
            Name.Size = 14
            Name.Center = true
            Name.Outline = true
            
            local Tracer = Drawing.new("Line")
            Tracer.Visible = false
            Tracer.Color = Color3.fromRGB(255, 255, 255)
            Tracer.Thickness = 1
            Tracer.Transparency = 1
            
            VisualSystem.ESP.Boxes[player] = Box
            VisualSystem.ESP.Names[player] = Name
            VisualSystem.ESP.Tracers[player] = Tracer
        end,
        
        UpdateESP = function()
            for player, box in pairs(VisualSystem.ESP.Boxes) do
                if IsAlive(player) and _G.Settings.Visuals.ESP then
                    local Character = player.Character
                    local Pos, OnScreen = Camera:WorldToViewportPoint(Character.HumanoidRootPart.Position)
                    
                    if OnScreen then
                        local Size = (Camera:WorldToViewportPoint(Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Character.HumanoidRootPart.Position + Vector3.new(0, 2.5, 0)).Y) / 2
                        local BoxSize = Vector2.new(math.floor(Size * 1.5), math.floor(Size * 1.8))
                        local BoxPos = Vector2.new(math.floor(Pos.X - Size * 1.5 / 2), math.floor(Pos.Y - Size * 1.8 / 2))
                        
                        box.Size = BoxSize
                        box.Position = BoxPos
                        box.Visible = _G.Settings.Visuals.ESPBoxes
                        
                        local name = VisualSystem.ESP.Names[player]
                        name.Text = player.Name
                        name.Position = Vector2.new(BoxPos.X + BoxSize.X / 2, BoxPos.Y - 15)
                        name.Visible = _G.Settings.Visuals.ESPNames
                        
                        local tracer = VisualSystem.ESP.Tracers[player]
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(Pos.X, Pos.Y)
                        tracer.Visible = _G.Settings.Visuals.ESPTracers
                    else
                        box.Visible = false
                        VisualSystem.ESP.Names[player].Visible = false
                        VisualSystem.ESP.Tracers[player].Visible = false
                    end
                else
                    box.Visible = false
                    VisualSystem.ESP.Names[player].Visible = false
                    VisualSystem.ESP.Tracers[player].Visible = false
                end
            end
        end
    }
}

-- Sistema de Aimbot
local AimbotSystem = {
    Initialize = function()
        RunService.RenderStepped:Connect(function()
            if _G.Settings.Aimbot.Enabled then
                FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
                FOVCircle.Visible = _G.Settings.Aimbot.ShowFOV
                
                local Target = GetClosestPlayer()
                if Target and IsAlive(Target) then
                    local TargetPart = Target.Character[_G.Settings.Aimbot.TargetPart]
                    local TargetPos = TargetPart.Position
                    
                    if _G.Settings.Aimbot.PredictionEnabled then
                        TargetPos = TargetPos + (Target.Character.HumanoidRootPart.Velocity * _G.Settings.Aimbot.PredictionAmount)
                    end
                    
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPos)
                    
                    if OnScreen then
                        -- Smooth Aim
                        local AimPos = Vector2.new(
                            (ScreenPos.X - Mouse.X) * _G.Settings.Aimbot.Smoothness,
                            (ScreenPos.Y - Mouse.Y) * _G.Settings.Aimbot.Smoothness
                        )
                        
                        -- Move Mouse
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                            mousemoverel(AimPos.X, AimPos.Y)
                            
                            -- Auto Shoot
                            if _G.Settings.Aimbot.AutoShoot then
                                mouse1click()
                            end
                        end
                    end
                end
            end
        end)
    end,
    
    InitializeSilentAim = function()
        local OldNameCall = nil
        OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
            local Args = {...}
            local Method = getnamecallmethod()
            
            if _G.Settings.Aimbot.SilentAim and Method == "FindPartOnRayWithIgnoreList" then
                local Target = GetClosestPlayer()
                if Target and IsAlive(Target) then
                    local TargetPart = Target.Character[_G.Settings.Aimbot.TargetPart]
                    Args[1] = Ray.new(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000)
                end
            end
            
            return OldNameCall(Self, unpack(Args))
        end)
    end
}

-- Sistema de AimLock
local AimLockSystem = {
    Target = nil,
    
    Initialize = function()
        RunService.RenderStepped:Connect(function()
            if _G.Settings.AimLock.Enabled and UserInputService:IsKeyDown(_G.Settings.AimLock.TriggerKey) then
                if not AimLockSystem.Target then
                    AimLockSystem.Target = GetClosestPlayer()
                end
                
                if AimLockSystem.Target and IsAlive(AimLockSystem.Target) then
                    local TargetPart = AimLockSystem.Target.Character[_G.Settings.AimLock.HeadLock and "Head" or "HumanoidRootPart"]
                    local TargetPos = TargetPart.Position
                    
                    if _G.Settings.AimLock.Prediction then
                        TargetPos = TargetPos + (AimLockSystem.Target.Character.HumanoidRootPart.Velocity * _G.Settings.AimLock.PredictionAmount)
                    end
                    
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPos)
                    
                    if OnScreen then
                        Camera.CFrame = Camera.CFrame:Lerp(
                            CFrame.new(Camera.CFrame.Position, TargetPos),
                            _G.Settings.AimLock.Smoothness
                        )
                        
                        if _G.Settings.AimLock.AutoShoot then
                            mouse1click()
                        end
                    end
                end
            else
                AimLockSystem.Target = nil
            end
        end)
    end
}

-- Sistema de Proteção
local ProtectionSystem = {
    Initialize = function()
        -- Anti Kick
        if _G.Settings.Protection.AntiKick then
            local OldNameCall = nil
            OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
                local Args = {...}
                local Method = getnamecallmethod()
                
                if Method == "Kick" or Method == "kick" then
                    return nil
                end
                
                return OldNameCall(Self, unpack(Args))
            end)
        end
        
        -- Anti Teleport
        if _G.Settings.Protection.AntiTeleport then
            local OldTeleport = nil
            OldTeleport = hookfunction(TeleportService.TeleportToPlaceInstance, function(...)
                return nil
            end)
        end
        
        -- Anti Cheat Bypass
        if _G.Settings.Protection.AntiCheatBypass then
            local gc = getgc(true)
            for i = 1, #gc do
                local obj = gc[i]
                if type(obj) == "table" then
                    if rawget(obj, "Kick") then obj.Kick = function() return end end
                    if rawget(obj, "kick") then obj.kick = function() return end end
                    if rawget(obj, "AntiCheat") then obj.AntiCheat = function() return end end
                end
            end
        end
        
        -- Speed/Jump Check Bypass
        if _G.Settings.Protection.AntiSpeedCheck or _G.Settings.Protection.AntiJumpCheck then
            local OldIndex = nil
            OldIndex = hookmetamethod(game, "__index", function(Self, Key)
                if not checkcaller() then
                    if Key == "WalkSpeed" and _G.Settings.Protection.AntiSpeedCheck then
                        return 16
                    end
                    if Key == "JumpPower" and _G.Settings.Protection.AntiJumpCheck then
                        return 50
                    end
                end
                return OldIndex(Self, Key)
            end)
        end
    end,
    
    DisableAntiCheats = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("LocalScript") and (v.Name:lower():find("anti") or v.Name:lower():find("cheat")) then
                v.Disabled = true
            end
        end
    end
}

-- Sistema de Segurança
local SecuritySystem = {
    Initialize = function()
        -- Proteção contra detecção de exploits
        local function SecureFunction(func)
            local env = getfenv(2)
            setfenv(func, setmetatable({}, {
                __index = function(_, key)
                    if key == "script" then
                        return {Disabled = false}
                    end
                    return env[key]
                end
            }))
        end
        
        -- Proteção contra logs
        for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
            v:Disable()
        end
        
        -- Proteção contra reports
        local OldNameCall = nil
        OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
            local Method = getnamecallmethod()
            if Method == "ReportAbuse" then
                return nil
            end
            return OldNameCall(Self, ...)
        end)
    end
}

-- Configuração das Tabs
local function SetupMovementTab()
    local SpeedSection = MovementTab:AddSection("Velocidade")
    SpeedSection:AddSlider({
        Name = "WalkSpeed",
        Min = 16,
        Max = 500,
        Default = 16,
        Increment = 1,
        ValueName = "Speed",
        Callback = function(Value)
            _G.Settings.Player.WalkSpeed = Value
            if IsAlive(Player) then
                Humanoid.WalkSpeed = Value
            end
        end
    })

    local JumpSection = MovementTab:AddSection("Pulo")
    JumpSection:AddSlider({
        Name = "JumpPower",
        Min = 50,
        Max = 500,
        Default = 50,
        Increment = 1,
        ValueName = "Power",
        Callback = function(Value)
            _G.Settings.Player.JumpPower = Value
            if IsAlive(Player) then
                Humanoid.JumpPower = Value
            end
        end
    })

    local FlySection = MovementTab:AddSection("Voo")
    FlySection:AddToggle({
        Name = "Fly",
        Default = false,
        Callback = function(Value)
            _G.Settings.Player.Flying = Value
            if Value then
                MovementSystem.EnableFly()
            end
        end
    })
end

local function SetupCombatTab()
    local MainSection = CombatTab:AddSection("Combate Principal")
    
    MainSection:AddToggle({
        Name = "Kill Aura",
        Default = false,
        Callback = function(Value)
            _G.Settings.Combat.KillAura = Value
        end
    })

    MainSection:AddSlider({
        Name = "Kill Aura Range",
        Min = 5,
        Max = 50,
        Default = 15,
        Increment = 1,
        ValueName = "Studs",
        Callback = function(Value)
            _G.Settings.Combat.KillAuraRange = Value
        end
    })

    local HitboxSection = CombatTab:AddSection("Hitbox")
    HitboxSection:AddToggle({
        Name = "Hitbox Expander",
        Default = false,
        Callback = function(Value)
            _G.Settings.Combat.HitboxExpander = Value
        end
    })
end

local function SetupAimbotTab()
    local MainSection = AimbotTab:AddSection("Aimbot Principal")
    
    MainSection:AddToggle({
        Name = "Aimbot",
        Default = false,
        Callback = function(Value)
            _G.Settings.Aimbot.Enabled = Value
        end
    })

    MainSection:AddToggle({
        Name = "Show FOV",
        Default = true,
        Callback = function(Value)
            _G.Settings.Aimbot.ShowFOV = Value
            FOVCircle.Visible = Value and _G.Settings.Aimbot.Enabled
        end
    })

    MainSection:AddSlider({
        Name = "FOV Size",
        Min = 50,
        Max = 800,
        Default = 400,
        Increment = 10,
        ValueName = "px",
        Callback = function(Value)
            _G.Settings.Aimbot.FOV = Value
            FOVCircle.Radius = Value
        end
    })

    MainSection:AddSlider({
        Name = "Smoothness",
        Min = 0,
        Max = 1,
        Default = 0.5,
        Increment = 0.01,
        ValueName = "",
        Callback = function(Value)
            _G.Settings.Aimbot.Smoothness = Value
        end
    })

    local AimLockSection = AimbotTab:AddSection("AimLock")
    AimLockSection:AddToggle({
        Name = "AimLock",
        Default = false,
        Callback = function(Value)
            _G.Settings.AimLock.Enabled = Value
        end
    })

    AimLockSection:AddBind({
        Name = "AimLock Key",
        Default = Enum.KeyCode.X,
        Hold = false,
        Callback = function()
            -- Key binding handled in AimLock system
        end    
    })
end

local function SetupVisualsTab()
    local ESPSection = VisualsTab:AddSection("ESP")
    
    ESPSection:AddToggle({
        Name = "Enable ESP",
        Default = false,
        Callback = function(Value)
            _G.Settings.Visuals.ESP = Value
        end
    })

    ESPSection:AddToggle({
        Name = "Box ESP",
        Default = false,
        Callback = function(Value)
            _G.Settings.Visuals.ESPBoxes = Value
        end
    })

    ESPSection:AddToggle({
        Name = "Name ESP",
        Default = false,
        Callback = function(Value)
            _G.Settings.Visuals.ESPNames = Value
        end
    })

    ESPSection:AddToggle({
        Name = "Tracer ESP",
        Default = false,
        Callback = function(Value)
            _G.Settings.Visuals.ESPTracers = Value
        end
    })
end

-- Inicialização do Script
local function Initialize()
    -- Setup Tabs
    SetupMovementTab()
    SetupCombatTab()
    SetupAimbotTab()
    SetupVisualsTab()

    -- Initialize Systems
    AimbotSystem.Initialize()
    AimbotSystem.InitializeSilentAim()
    AimLockSystem.Initialize()
    ProtectionSystem.Initialize()
    SecuritySystem.Initialize()
    
    -- ESP Setup
    Players.PlayerAdded:Connect(function(player)
        VisualSystem.ESP.CreateESP(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if VisualSystem.ESP.Boxes[player] then
            VisualSystem.ESP.Boxes[player]:Remove()
            VisualSystem.ESP.Names[player]:Remove()
            VisualSystem.ESP.Tracers[player]:Remove()
            
            VisualSystem.ESP.Boxes[player] = nil
            VisualSystem.ESP.Names[player] = nil
            VisualSystem.ESP.Tracers[player] = nil
        end
    end)
    
    -- Initial ESP Creation
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            VisualSystem.ESP.CreateESP(player)
        end
    end
    
    -- ESP Update Loop
    RunService.RenderStepped:Connect(function()
        VisualSystem.ESP.UpdateESP()
    end)
    
    -- Character Added Handler
    Player.CharacterAdded:Connect(function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid")
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
        
        -- Reset values
        if _G.Settings.Player.WalkSpeed ~= 16 then
            Humanoid.WalkSpeed = _G.Settings.Player.WalkSpeed
        end
        if _G.Settings.Player.JumpPower ~= 50 then
            Humanoid.JumpPower = _G.Settings.Player.JumpPower
        end
    end)
    
    -- Notification de Inicialização
    Library:Notify({
        Title = "Galaxy Hub Premium",
        Content = "Script carregado com sucesso!",
        Duration = 5
    })
end

-- Iniciar o Script
Initialize()
