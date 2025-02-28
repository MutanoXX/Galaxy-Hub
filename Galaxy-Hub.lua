-- Galaxy-Hub-Minigames V2
-- Sistema Anti-Detection
local AntiDetection = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaQLeak/AntiCheatBypass.lua"))()
local Security = loadstring(game:HttpGet("https://raw.githubusercontent.com/SecurityLua/Bypass.lua"))()

-- Interface Aprimorada
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = Library:MakeWindow({
    Name = "Galaxy Hub Premium",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "GalaxyConfigs",
    IntroEnabled = true,
    IntroText = "Galaxy Hub - Premium Version"
})

-- Variáveis Globais Aprimoradas
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
_G.Settings = {
    Speed = {
        Enabled = false,
        Value = 16,
        BypassPhysics = true
    },
    Jump = {
        Enabled = false,
        Value = 50,
        InfiniteJump = false
    },
    Multiplier = {
        Enabled = false,
        Value = 2,
        AutoCollect = false
    },
    Protection = {
        AntiKick = true,
        AntiTeleport = true,
        AntiSpeed = true,
        AntiJump = true
    }
}

-- Bypass Sistema
local function BypassAnticheat()
    local gc = getgc(true)
    for i = 1, #gc do
        local obj = gc[i]
        if type(obj) == "table" then
            if rawget(obj, "Kick") then
                obj.Kick = function() return end
            end
            if rawget(obj, "AntiCheat") then
                obj.AntiCheat = function() return end
            end
        end
    end
    
    -- Bypass Detection
    for _, v in pairs(getloadedmodules()) do
        if v.Name:find("Security") or v.Name:find("Anti") then
            v:Destroy()
        end
    end
end

-- Tabs Aprimorados
local MainTab = Window:MakeTab({Name = "Principal", Icon = "rbxassetid://4483345998"})
local SpeedTab = Window:MakeTab({Name = "Velocidade", Icon = "rbxassetid://4483345998"})
local JumpTab = Window:MakeTab({Name = "Super Pulo", Icon = "rbxassetid://4483345998"})
local MultiplierTab = Window:MakeTab({Name = "Multiplicador", Icon = "rbxassetid://4483345998"})
local ProtectionTab = Window:MakeTab({Name = "Proteção", Icon = "rbxassetid://4483345998"})

-- Sistema de Velocidade Aprimorado
SpeedTab:AddSlider({
    Name = "Velocidade",
    Min = 16,
    Max = 5000,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Velocidade",
    Callback = function(Value)
        _G.Settings.Speed.Value = Value
        if _G.Settings.Speed.Enabled then
            local function ApplySpeed()
                if Character and Character:FindFirstChild("Humanoid") then
                    Humanoid.WalkSpeed = Value
                    
                    -- Bypass Speed Checks
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "table" and rawget(v, "speed") then
                            v.speed = Value
                        end
                    end
                end
            end
            ApplySpeed()
        end
    end    
})

-- Sistema de Super Pulo Aprimorado
JumpTab:AddSlider({
    Name = "Força do Pulo",
    Min = 50,
    Max = 5000,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Força",
    Callback = function(Value)
        _G.Settings.Jump.Value = Value
        if _G.Settings.Jump.Enabled then
            Humanoid.JumpPower = Value
            -- Bypass Jump Restrictions
            local mt = getrawmetatable(game)
            local oldIndex = mt.__index
            setreadonly(mt, false)
            mt.__index = newcclosure(function(self,k)
                if k == "JumpPower" then
                    return _G.Settings.Jump.Value
                end
                return oldIndex(self,k)
            end)
        end
    end    
})

-- Sistema de Multiplicador Aprimorado
MultiplierTab:AddSlider({
    Name = "Multiplicador",
    Min = 1,
    Max = 100,
    Default = 2,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "x",
    Callback = function(Value)
        _G.Settings.Multiplier.Value = Value
    end    
})

-- Sistema de Proteção
ProtectionTab:AddToggle({
    Name = "Anti-Kick",
    Default = true,
    Callback = function(Value)
        _G.Settings.Protection.AntiKick = Value
        if Value then
            local OldNameCall = nil
            OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
                local Args = {...}
                local Method = getnamecallmethod()
                if Method == "Kick" or Method == "kick" then
                    return nil
                end
                return OldNameCall(Self, ...)
            end)
        end
    end    
})

-- Hook Universal para Multiplicador
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if _G.Settings.Multiplier.Enabled then
        if method == "FireServer" or method == "InvokeServer" then
            for i, v in pairs(args) do
                if type(v) == "number" then
                    args[i] = v * _G.Settings.Multiplier.Value
                elseif type(v) == "table" then
                    for j, k in pairs(v) do
                        if type(k) == "number" then
                            v[j] = k * _G.Settings.Multiplier.Value
                        end
                    end
                end
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Auto-Update e Proteção
game:GetService("RunService").Heartbeat:Connect(function()
    if _G.Settings.Speed.Enabled then
        Humanoid.WalkSpeed = _G.Settings.Speed.Value
    end
    if _G.Settings.Jump.Enabled then
        Humanoid.JumpPower = _G.Settings.Jump.Value
    end
    BypassAnticheat()
end)

-- Proteção Adicional
local function SecureScript()
    local env = getfenv(2)
    local protected = {
        ["print"] = print,
        ["warn"] = warn,
        ["error"] = error
    }
    setmetatable(env, {
        __index = function(_, key)
            if protected[key] then
                return protected[key]
            end
            return getfenv(0)[key]
        end
    })
end
SecureScript()

-- Inicialização
BypassAnticheat()
Library:Init()

-- Notificação de Inicialização
Library:MakeNotification({
    Name = "Galaxy Hub Premium",
    Content = "Script carregado com sucesso!",
    Image = "rbxassetid://4483345998",
    Time = 5
})
