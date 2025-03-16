local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ButtonsHolder = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local StatusLabel = Instance.new("TextLabel")
local UIStroke = Instance.new("UIStroke")
local UIGradient = Instance.new("UIGradient")

ScreenGui.Name = "Test-Hub-Otimization"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

UIStroke.Color = Color3.fromRGB(147, 112, 219) -- Cor roxa para borda
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Test-Hub-Otimization"
Title.TextColor3 = Color3.fromRGB(147, 112, 219) -- Cor roxa para título
Title.TextSize = 20

ButtonsHolder.Name = "ButtonsHolder"
ButtonsHolder.Parent = MainFrame
ButtonsHolder.BackgroundTransparency = 1
ButtonsHolder.Position = UDim2.new(0, 10, 0, 40)
ButtonsHolder.Size = UDim2.new(1, -20, 1, -50)

UIListLayout.Parent = ButtonsHolder
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 1, -25)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.Text = "FPS: 60 | Memory: 0MB"
StatusLabel.TextColor3 = Color3.fromRGB(147, 112, 219)
StatusLabel.TextSize = 14

-- Funções de Otimização
local OptimizationFunctions = {
    FPSBoost = function()
        settings().Rendering.QualityLevel = 1
        settings().Physics.PhysicsEnvironmentalThrottle = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        RunService:Set3dRenderingEnabled(false)
        settings().Physics.PhysicsEnvironmentalThrottle = 1
        settings().Physics.ForceCSGv2 = false
        settings().Physics.DisableCSGv2 = true
        settings().Physics.UseCSGv2 = false
        settings().Rendering.EagerBulkExecution = true
    end,

    MemoryCleaner = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CastShadow = false
            end
        end
        game:GetService("Debris"):SetAutoCleanupEnabled(true)
        settings().Physics.PhysicsEnvironmentalThrottle = 1
        settings().Rendering.MeshCacheSize = 0
        settings().Rendering.AnimationWeighting = false
        collectgarbage("collect")
    end,

    NetworkOptimizer = function()
        settings().Physics.NetworkOwnershipRule = Enum.NetworkOwnership.Manual
        settings().Physics.PhysicsEnvironmentalThrottle = 1
        settings().Physics.ForceCSGv2 = false
        settings().Physics.DisableCSGv2 = true
        settings().Network.IncomingReplicationLag = 0
    end,

    GraphicsReducer = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
        
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
    end,

    AutoOptimizer = function()
        local function autoOptimize()
            local fps = math.floor(1/RunService.RenderStepped:Wait())
            if fps < 30 then
                OptimizationFunctions.FPSBoost()
                OptimizationFunctions.GraphicsReducer()
            elseif fps < 60 then
                OptimizationFunctions.MemoryCleaner()
            end
        end
        
        RunService.RenderStepped:Connect(autoOptimize)
    end
}

-- Função para criar botões
local function CreateButton(name, callback)
    local Button = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local enabled = false
    
    Button.Name = name
    Button.Parent = ButtonsHolder
    Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.AutoButtonColor = false
    
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        }):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback()
        Button.TextColor3 = enabled and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(255, 255, 255)
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        }):Play()
        wait(0.1)
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        }):Play()
    end)
    
    return Button
end

-- Criar botões para cada função
CreateButton("FPS Boost", OptimizationFunctions.FPSBoost)
CreateButton("Memory Cleaner", OptimizationFunctions.MemoryCleaner)
CreateButton("Network Optimizer", OptimizationFunctions.NetworkOptimizer)
CreateButton("Graphics Reducer", OptimizationFunctions.GraphicsReducer)
CreateButton("Auto Optimizer", OptimizationFunctions.AutoOptimizer)

-- Atualizar status
RunService.RenderStepped:Connect(function()
    local fps = math.floor(1/RunService.RenderStepped:Wait())
    local memory = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
    StatusLabel.Text = string.format("FPS: %d | Memory: %dMB", fps, memory)
end)

-- Toggle do menu com RightControl
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Notificação inicial
game.StarterGui:SetCore("SendNotification", {
    Title = "Test-Hub-Otimization",
    Text = "Press RightControl to toggle menu",
    Duration = 5
})
