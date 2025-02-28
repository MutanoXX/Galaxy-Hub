-- Galaxy Hub Universal V4 Premium
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()

local PhantomForcesWindow = Library:NewWindow("Galaxy Hub Premium")

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Variáveis Principais
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Configurações
_G.Settings = {
    Speed = {
        Enabled = false,
        Value = 16,
        Type = "Normal",
        BypassType = "Advanced",
        VehicleSpeed = false,
        CustomMethod = 1
    },
    Jump = {
        Enabled = false,
        Value = 50,
        InfiniteJump = false,
        JumpType = "Normal",
        DoubleJump = false,
        AirJump = false
    },
    Character = {
        GodMode = false,
        NoClip = false,
        AutoRespawn = false,
        AntiRagdoll = false,
        AntiStun = false,
        AntiFling = false
    },
    Combat = {
        KillAura = false,
        Range = 15,
        Damage = 100,
        AutoParry = false,
        SilentAim = false,
        Aimbot = false,
        WallBang = false
    },
    Multiplier = {
        Enabled = false,
        Value = 2,
        Types = {
            Money = true,
            Experience = true,
            Items = true,
            Custom = false
        }
    },
    Protection = {
        AntiKick = true,
        AntiTeleport = true,
        AntiBan = true,
        AntiReport = true,
        BypassSpeed = true,
        BypassJump = true
    },
    Visual = {
        ESP = false,
        Tracers = false,
        BoxESP = false,
        NameTags = false,
        Chams = false
    }
}

-- Sistema Anti-Detecção Avançado
local function CreateSecuritySystem()
    local SecuritySystem = {
        Hooks = {},
        ProtectedFunctions = {},
        DetectionBypass = {}
    }

    function SecuritySystem:BypassDetection()
        local gc = getgc(true)
        for i = 1, #gc do
            local obj = gc[i]
            if type(obj) == "table" then
                for k, v in pairs(obj) do
                    if type(v) == "function" then
                        local constants = debug.getconstants(v)
                        for _, constant in ipairs(constants) do
                            if tostring(constant):lower():find("cheat") or tostring(constant):lower():find("hack") then
                                debug.setupvalue(v, 1, function() return false end)
                            end
                        end
                    end
                end
            end
        end
    end

    function SecuritySystem:HookFunction(func, callback)
        local old
        old = hookfunction(func, function(...)
            return callback(old, ...)
        end)
    end

    function SecuritySystem:ProtectRemote(remote)
        local old = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            if _G.Settings.Multiplier.Enabled then
                for i, v in pairs(args) do
                    if type(v) == "number" then
                        args[i] = v * _G.Settings.Multiplier.Value
                    end
                end
            end
            return old(self, unpack(args))
        end
    end

    return SecuritySystem
end

-- Sistema de Velocidade Avançado
local SpeedSystem = {
    Methods = {
        Normal = function(speed)
            Humanoid.WalkSpeed = speed
        end,
        CFrame = function(speed)
            RunService.Heartbeat:Connect(function()
                if _G.Settings.Speed.Enabled then
                    local vel = HumanoidRootPart.CFrame.LookVector * speed
                    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + vel * RunService.Heartbeat:Wait()
                end
            end)
        end,
        Velocity = function(speed)
            RunService.Heartbeat:Connect(function()
                if _G.Settings.Speed.Enabled then
                    HumanoidRootPart.Velocity = HumanoidRootPart.CFrame.LookVector * speed
                end
            end)
        end
    }
}

-- Sistema de Pulo Avançado
local JumpSystem = {
    EnableDoubleJump = function()
        local jumps = 0
        UserInputService.JumpRequest:Connect(function()
            if _G.Settings.Jump.DoubleJump then
                if jumps < 2 then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    jumps = jumps + 1
                end
            end
        end)
        Humanoid.StateChanged:Connect(function(old, new)
            if new == Enum.HumanoidStateType.Landed then
                jumps = 0
            end
        end)
    end,
    
    EnableInfiniteJump = function()
        UserInputService.JumpRequest:Connect(function()
            if _G.Settings.Jump.InfiniteJump then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
}

-- Sistema de Combate
local CombatSystem = {
    InitKillAura = function()
        RunService.Heartbeat:Connect(function()
            if _G.Settings.Combat.KillAura then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character then
                        local enemy = player.Character
                        local distance = (HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                        if distance <= _G.Settings.Combat.Range then
                            -- Implementar lógica de dano aqui
                        end
                    end
                end
            end
        end)
    end,
    
    InitSilentAim = function()
        -- Implementar Silent Aim
    end
}

-- Interface Principal
local MainTab = PhantomForcesWindow:NewSection("Principal")
local SpeedTab = PhantomForcesWindow:NewSection("Velocidade")
local JumpTab = PhantomForcesWindow:NewSection("Pulo")
local CombatTab = PhantomForcesWindow:NewSection("Combate")
local VisualTab = PhantomForcesWindow:NewSection("Visual")
local MultiTab = PhantomForcesWindow:NewSection("Multiplicador")
local ProtectionTab = PhantomForcesWindow:NewSection("Proteção")

-- Speed Tab
SpeedTab:CreateToggle("Ativar Speed", function(state)
    _G.Settings.Speed.Enabled = state
end)

SpeedTab:CreateSlider("Velocidade", 16, 1000, 16, function(value)
    _G.Settings.Speed.Value = value
end)

SpeedTab:CreateDropdown("Método", {"Normal", "CFrame", "Velocity"}, function(selected)
    _G.Settings.Speed.Type = selected
end)

-- Jump Tab
JumpTab:CreateToggle("Super Pulo", function(state)
    _G.Settings.Jump.Enabled = state
end)

JumpTab:CreateSlider("Força do Pulo", 50, 1000, 50, function(value)
    _G.Settings.Jump.Value = value
end)

JumpTab:CreateToggle("Pulo Infinito", function(state)
    _G.Settings.Jump.InfiniteJump = state
end)

-- Combat Tab
CombatTab:CreateToggle("Kill Aura", function(state)
    _G.Settings.Combat.KillAura = state
end)

CombatTab:CreateToggle("Silent Aim", function(state)
    _G.Settings.Combat.SilentAim = state
end)

-- Multiplier Tab
MultiTab:CreateToggle("Ativar Multiplicador", function(state)
    _G.Settings.Multiplier.Enabled = state
end)

MultiTab:CreateSlider("Valor", 2, 100, 2, function(value)
    _G.Settings.Multiplier.Value = value
end)

-- Protection Tab
ProtectionTab:CreateToggle("Anti-Kick", function(state)
    _G.Settings.Protection.AntiKick = state
end)

ProtectionTab:CreateToggle("Anti-Ban", function(state)
    _G.Settings.Protection.AntiBan = state
end)

-- Inicialização
local Security = CreateSecuritySystem()
Security:BypassDetection()

SpeedSystem.Methods[_G.Settings.Speed.Type](_G.Settings.Speed.Value)
JumpSystem.EnableDoubleJump()
JumpSystem.EnableInfiniteJump()
CombatSystem.InitKillAura()
CombatSystem.InitSilentAim()

-- Anti-Kick
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if _G.Settings.Protection.AntiKick and method == "Kick" then
        return nil
    end
    
    if _G.Settings.Multiplier.Enabled and method == "FireServer" then
        for i, v in pairs(args) do
            if type(v) == "number" then
                args[i] = v * _G.Settings.Multiplier.Value
            end
        end
    end
    
    return old(self, unpack(args))
end)

-- Auto-Update
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    
    if _G.Settings.Speed.Enabled then
        SpeedSystem.Methods[_G.Settings.Speed.Type](_G.Settings.Speed.Value)
    end
    
    if _G.Settings.Jump.Enabled then
        Humanoid.JumpPower = _G.Settings.Jump.Value
    end
end)
