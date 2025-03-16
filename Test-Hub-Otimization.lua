-- Sistema de Segurança Avançado e Configurações Iniciais
local SecuritySystem = {
    MemoryEncryption = true,
    AntiTamper = true,
    AntiDebug = true,
    DataEncryption = true,
    EnvironmentProtection = true
}

-- Serviços do Roblox
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Configurações Globais
local Config = {
    MenuWidth = 600,
    MenuHeight = 400,
    MinimizedHeight = 40,
    SaveFileName = "TestHub_Settings.json",
    EncryptionKey = string.rep(string.char(math.random(0, 255)), 32),
    Colors = {
        Background = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(147, 112, 219),
        Button = Color3.fromRGB(20, 20, 20),
        ButtonHover = Color3.fromRGB(30, 30, 30),
        TextEnabled = Color3.fromRGB(147, 112, 219),
        TextDisabled = Color3.fromRGB(255, 255, 255),
        CategorySelected = Color3.fromRGB(40, 40, 40),
        CategoryUnselected = Color3.fromRGB(20, 20, 20),
        ESP = {
            Box = Color3.fromRGB(255, 0, 0),
            Skeleton = Color3.fromRGB(255, 255, 255),
            HealthBar = Color3.fromRGB(0, 255, 0),
            Distance = Color3.fromRGB(255, 255, 0),
            Name = Color3.fromRGB(255, 0, 255)
        },
        Aimbot = {
            FOV = Color3.fromRGB(255, 255, 255),
            Target = Color3.fromRGB(255, 0, 0)
        }
    }
}

-- Sistema de Segurança Avançado
local SecurityFunctions = {
    -- Proteção contra Debug
    AntiDebug = function()
        local function protectFunction(func)
            local protected = newcclosure(func)
            return protected
        end

        local blockedFunctions = {
            "getgc",
            "getcallingscript",
            "getrenv",
            "getfenv",
            "debug.getupvalue",
            "debug.setupvalue",
            "debug.getregistry"
        }

        for _, funcName in pairs(blockedFunctions) do
            local success, result = pcall(function()
                local original = getfenv(0)[funcName]
                if original then
                    getfenv(0)[funcName] = protectFunction(function()
                        return nil
                    end)
                end
            end)
        end
    end,

    -- Proteção contra Memory Scanning
    MemoryProtection = function()
        local function encryptMemory(data)
            local encrypted = ""
            for i = 1, #data do
                encrypted = encrypted .. string.char(bit32.bxor(string.byte(data, i), string.byte(Config.EncryptionKey, (i-1) % #Config.EncryptionKey + 1)))
            end
            return encrypted
        end

        local function decryptMemory(data)
            return encryptMemory(data) -- XOR é reversível
        end

        -- Proteção de Strings
        local stringCache = {}
        local stringMetatable = getmetatable("")
        local originalIndex = stringMetatable.__index

        stringMetatable.__index = newcclosure(function(t, k)
            if type(k) == "string" then
                if not stringCache[k] then
                    stringCache[k] = encryptMemory(k)
                end
                k = stringCache[k]
            end
            return originalIndex(t, k)
        end)
    end,

    -- Sistema Anti-Ban
    AntiBan = function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if method == "FireServer" or method == "InvokeServer" then
                -- Lista de eventos suspeitos
                local suspiciousEvents = {
                    "Ban",
                    "Kick",
                    "Report",
                    "Detection",
                    "Security"
                }

                for _, event in pairs(suspiciousEvents) do
                    if string.find(string.lower(self.Name), string.lower(event)) then
                        return nil
                    end
                end

                -- Verificação de argumentos suspeitos
                for _, arg in pairs(args) do
                    if type(arg) == "string" then
                        local lowerArg = string.lower(arg)
                        if string.find(lowerArg, "exploit") or 
                           string.find(lowerArg, "cheat") or 
                           string.find(lowerArg, "hack") then
                            return nil
                        end
                    end
                end
            end

            return oldNamecall(self, ...)
        end)

        setreadonly(mt, true)
    end,

    -- Sistema Anti-Detecção
    AntiDetection = function()
        -- Proteção contra verificações de ambiente
        local function createProxyTable(original)
            local proxy = {}
            local mt = {
                __index = function(_, k)
                    if type(original[k]) == "table" then
                        return createProxyTable(original[k])
                    end
                    return original[k]
                end,
                __newindex = function(_, k, v)
                    original[k] = v
                end,
                __metatable = "Locked"
            }
            setmetatable(proxy, mt)
            return proxy
        end

        -- Proteção do ambiente global
        _G = createProxyTable(_G)
        shared = createProxyTable(shared)

        -- Proteção contra detecção de scripts
        local function hideScript()
            local fakeScript = Instance.new("LocalScript")
            fakeScript.Name = "GameScript"
            fakeScript.Parent = LocalPlayer.PlayerGui

            local realScript = getfenv(2).script
            if realScript then
                realScript.Name = string.rep("\0", math.random(1, 10))
                realScript.Parent = nil
            end
        end

        hideScript()
    end,

    -- Inicialização do Sistema de Segurança
    Initialize = function()
        if SecuritySystem.AntiDebug then
            SecurityFunctions.AntiDebug()
        end
        if SecuritySystem.MemoryEncryption then
            SecurityFunctions.MemoryProtection()
        end
        if SecuritySystem.AntiTamper then
            SecurityFunctions.AntiBan()
        end
        if SecuritySystem.EnvironmentProtection then
            SecurityFunctions.AntiDetection()
        end
    end
}

-- Inicializar Sistema de Segurança
SecurityFunctions.Initialize()

-- Sistema de Persistência de Dados
local DataSystem = {
    SavedData = {},
    BackupInterval = 300, -- 5 minutos
    MaxBackups = 3
}

-- Funções de Criptografia para Dados
local CryptoFunctions = {
    GenerateKey = function()
        local key = ""
        for i = 1, 32 do
            key = key .. string.char(math.random(33, 126))
        end
        return key
    end,

    Encrypt = function(data, key)
        if type(data) ~= "string" then
            data = HttpService:JSONEncode(data)
        end
        
        local encrypted = ""
        local keyLength = #key
        
        for i = 1, #data do
            local byte = string.byte(data, i)
            local keyByte = string.byte(key, ((i-1) % keyLength) + 1)
            encrypted = encrypted .. string.char(bit32.bxor(byte, keyByte))
        end
        
        return game:GetService("HttpService"):JSONEncode({
            data = encrypted,
            hash = CryptoFunctions.GenerateHash(encrypted)
        })
    end,

    Decrypt = function(encryptedData, key)
        local success, data = pcall(function()
            local decoded = game:GetService("HttpService"):JSONDecode(encryptedData)
            if decoded.hash ~= CryptoFunctions.GenerateHash(decoded.data) then
                return nil
            end
            
            local decrypted = ""
            local keyLength = #key
            
            for i = 1, #decoded.data do
                local byte = string.byte(decoded.data, i)
                local keyByte = string.byte(key, ((i-1) % keyLength) + 1)
                decrypted = decrypted .. string.char(bit32.bxor(byte, keyByte))
            end
            
            return game:GetService("HttpService"):JSONDecode(decrypted)
        end)
        
        return success and data or nil
    end,

    GenerateHash = function(data)
        local hash = 0
        for i = 1, #data do
            hash = hash * 31 + string.byte(data, i)
            hash = hash % 2^32
        end
        return hash
    end
}

-- Sistema de Gerenciamento de Dados
local DataManager = {
    SaveData = function(data)
        local success, result = pcall(function()
            -- Criar diretório se não existir
            if not isfolder("TestHub") then
                makefolder("TestHub")
            end
            
            -- Salvar dados principais
            local encryptedData = CryptoFunctions.Encrypt(data, Config.EncryptionKey)
            writefile("TestHub/" .. Config.SaveFileName, encryptedData)
            
            -- Criar backup
            local timestamp = os.time()
            local backupName = string.format("TestHub/backup_%d.json", timestamp)
            writefile(backupName, encryptedData)
            
            -- Gerenciar backups antigos
            local backups = {}
            for _, file in pairs(listfiles("TestHub")) do
                if string.match(file, "backup_%d+.json") then
                    table.insert(backups, file)
                end
            end
            
            -- Manter apenas os backups mais recentes
            table.sort(backups, function(a, b)
                local timeA = tonumber(string.match(a, "%d+"))
                local timeB = tonumber(string.match(b, "%d+"))
                return timeA > timeB
            end)
            
            while #backups > DataSystem.MaxBackups do
                delfile(backups[#backups])
                table.remove(backups)
            end
        end)
        
        return success
    end,

    LoadData = function()
        local success, data = pcall(function()
            if not isfolder("TestHub") then
                return nil
            end
            
            -- Tentar carregar arquivo principal
            if isfile("TestHub/" .. Config.SaveFileName) then
                local encrypted = readfile("TestHub/" .. Config.SaveFileName)
                local decrypted = CryptoFunctions.Decrypt(encrypted, Config.EncryptionKey)
                
                if decrypted then
                    return decrypted
                end
            end
            
            -- Se falhar, tentar carregar do backup mais recente
            local backups = {}
            for _, file in pairs(listfiles("TestHub")) do
                if string.match(file, "backup_%d+.json") then
                    table.insert(backups, file)
                end
            end
            
            if #backups > 0 then
                table.sort(backups, function(a, b)
                    local timeA = tonumber(string.match(a, "%d+"))
                    local timeB = tonumber(string.match(b, "%d+"))
                    return timeA > timeB
                end)
                
                local encrypted = readfile(backups[1])
                return CryptoFunctions.Decrypt(encrypted, Config.EncryptionKey)
            end
            
            return nil
        end)
        
        return success and data or nil
    end,

    -- Sistema de Auto-Save
    InitializeAutoSave = function()
        spawn(function()
            while wait(DataSystem.BackupInterval) do
                DataManager.SaveData(DataSystem.SavedData)
            end
        end)
    end,

    -- Sistema de Migração de Dados
    MigrateData = function(oldData)
        local newData = {}
        
        -- Estrutura de dados atual
        local dataStructure = {
            version = "1.0",
            settings = {
                esp = {
                    enabled = false,
                    boxes = false,
                    tracers = false,
                    names = false,
                    distance = false,
                    health = false,
                    skeleton = false,
                    colors = {
                        boxes = Color3.new(1, 0, 0),
                        tracers = Color3.new(1, 1, 1),
                        names = Color3.new(1, 1, 0)
                    }
                },
                aimbot = {
                    enabled = false,
                    smoothing = 1,
                    fov = 100,
                    targetPart = "Head",
                    teamCheck = true,
                    visibilityCheck = true,
                    predictionEnabled = false,
                    predictionAmount = 1
                },
                utility = {
                    speedEnabled = false,
                    speedMultiplier = 2,
                    jumpEnabled = false,
                    jumpMultiplier = 2,
                    noClip = false,
                    infiniteJump = false
                }
            },
            profiles = {}
        }
        
        -- Migrar dados antigos para nova estrutura
        if oldData then
            for key, value in pairs(dataStructure) do
                if oldData[key] then
                    if type(value) == "table" then
                        newData[key] = DataManager.MergeSettings(value, oldData[key])
                    else
                        newData[key] = oldData[key]
                    end
                else
                    newData[key] = value
                end
            end
        else
            newData = dataStructure
        end
        
        return newData
    end,

    -- Função auxiliar para mesclar configurações
    MergeSettings = function(default, custom)
        local merged = {}
        for key, value in pairs(default) do
            if custom[key] ~= nil then
                if type(value) == "table" then
                    merged[key] = DataManager.MergeSettings(value, custom[key])
                else
                    merged[key] = custom[key]
                end
            else
                merged[key] = value
            end
        end
        return merged
    end
}

-- Inicialização do Sistema de Dados
local function InitializeDataSystem()
    local savedData = DataManager.LoadData()
    DataSystem.SavedData = DataManager.MigrateData(savedData)
    DataManager.InitializeAutoSave()
end

InitializeDataSystem()

-- Sistema de Interface
local UI = {
    Windows = {},
    ActiveMiniMenus = {},
    Dragging = false,
    DragStart = nil,
    StartPosition = nil
}

-- Criação da Interface Principal
local function CreateMainInterface()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local CategoryHolder = Instance.new("Frame")
    local CategoryList = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    local ContentHolder = Instance.new("Frame")
    local MinimizeButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    local UIStroke = Instance.new("UIStroke")

    -- Configurações de Interface
    ScreenGui.Name = "TestHubV2"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Config.Colors.Background
    MainFrame.Position = UDim2.new(0.5, -Config.MenuWidth/2, 0.5, -Config.MenuHeight/2)
    MainFrame.Size = UDim2.new(0, Config.MenuWidth, 0, Config.MenuHeight)
    MainFrame.Active = true
    MainFrame.Draggable = false -- Implementaremos nosso próprio sistema de drag

    -- Sistema de Drag Personalizado
    local function UpdateDrag(input)
        if UI.Dragging and UI.DragStart and UI.StartPosition then
            local delta = input.Position - UI.DragStart
            MainFrame.Position = UDim2.new(
                UI.StartPosition.X.Scale,
                UI.StartPosition.X.Offset + delta.X,
                UI.StartPosition.Y.Scale,
                UI.StartPosition.Y.Offset + delta.Y
            )
        end
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UI.Dragging = true
            UI.DragStart = input.Position
            UI.StartPosition = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateDrag(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UI.Dragging = false
            UI.DragStart = nil
            UI.StartPosition = nil
        end
    end)

    -- Criação do Mini-Menu
    local function CreateMiniMenu(title, options, position)
        local MiniMenu = Instance.new("Frame")
        local MiniMenuTitle = Instance.new("TextLabel")
        local MiniMenuContent = Instance.new("Frame")
        local MiniMenuList = Instance.new("UIListLayout")
        local MiniMenuCorner = Instance.new("UICorner")
        local MiniMenuStroke = Instance.new("UIStroke")

        MiniMenu.Name = "MiniMenu_" .. title
        MiniMenu.Parent = ScreenGui
        MiniMenu.BackgroundColor3 = Config.Colors.Background
        MiniMenu.Position = position
        MiniMenu.Size = UDim2.new(0, 200, 0, 250)
        MiniMenu.Visible = true

        MiniMenuCorner.CornerRadius = UDim.new(0, 8)
        MiniMenuCorner.Parent = MiniMenu

        MiniMenuStroke.Color = Config.Colors.Border
        MiniMenuStroke.Thickness = 1
        MiniMenuStroke.Parent = MiniMenu

        MiniMenuTitle.Name = "Title"
        MiniMenuTitle.Parent = MiniMenu
        MiniMenuTitle.BackgroundTransparency = 1
        MiniMenuTitle.Position = UDim2.new(0, 10, 0, 5)
        MiniMenuTitle.Size = UDim2.new(1, -20, 0, 25)
        MiniMenuTitle.Font = Enum.Font.GothamBold
        MiniMenuTitle.Text = title
        MiniMenuTitle.TextColor3 = Config.Colors.TextEnabled
        MiniMenuTitle.TextSize = 14

        MiniMenuContent.Name = "Content"
        MiniMenuContent.Parent = MiniMenu
        MiniMenuContent.BackgroundTransparency = 1
        MiniMenuContent.Position = UDim2.new(0, 5, 0, 35)
        MiniMenuContent.Size = UDim2.new(1, -10, 1, -40)

        MiniMenuList.Parent = MiniMenuContent
        MiniMenuList.SortOrder = Enum.SortOrder.LayoutOrder
        MiniMenuList.Padding = UDim.new(0, 5)

        -- Adicionar opções ao mini-menu
        for name, option in pairs(options) do
            local OptionFrame = Instance.new("Frame")
            local OptionLabel = Instance.new("TextLabel")
            local OptionInput = Instance.new("TextBox")
            
            OptionFrame.Name = name
            OptionFrame.Parent = MiniMenuContent
            OptionFrame.BackgroundTransparency = 1
            OptionFrame.Size = UDim2.new(1, 0, 0, 25)

            OptionLabel.Name = "Label"
            OptionLabel.Parent = OptionFrame
            OptionLabel.BackgroundTransparency = 1
            OptionLabel.Position = UDim2.new(0, 0, 0, 0)
            OptionLabel.Size = UDim2.new(0.5, -5, 1, 0)
            OptionLabel.Font = Enum.Font.Gotham
            OptionLabel.Text = name
            OptionLabel.TextColor3 = Config.Colors.TextDisabled
            OptionLabel.TextSize = 12
            OptionLabel.TextXAlignment = Enum.TextXAlignment.Left

            if option.type == "color" then
                local ColorPicker = Instance.new("TextButton")
                ColorPicker.Name = "ColorPicker"
                ColorPicker.Parent = OptionFrame
                ColorPicker.Position = UDim2.new(0.5, 5, 0, 0)
                ColorPicker.Size = UDim2.new(0.5, -5, 1, 0)
                ColorPicker.BackgroundColor3 = option.default or Color3.new(1, 1, 1)
                
                local ColorPickerCorner = Instance.new("UICorner")
                ColorPickerCorner.CornerRadius = UDim.new(0, 4)
                ColorPickerCorner.Parent = ColorPicker
                
                ColorPicker.MouseButton1Click:Connect(function()
                    -- Implementar color picker aqui
                end)
            else
                OptionInput.Name = "Input"
                OptionInput.Parent = OptionFrame
                OptionInput.Position = UDim2.new(0.5, 5, 0, 0)
                OptionInput.Size = UDim2.new(0.5, -5, 1, 0)
                OptionInput.BackgroundColor3 = Config.Colors.Button
                OptionInput.Font = Enum.Font.Gotham
                OptionInput.Text = tostring(option.default or "")
                OptionInput.TextColor3 = Config.Colors.TextEnabled
                OptionInput.TextSize = 12
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = OptionInput
                
                OptionInput.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        if option.type == "number" then
                            local num = tonumber(OptionInput.Text)
                            if num then
                                option.value = math.clamp(num, option.min or -math.huge, option.max or math.huge)
                                OptionInput.Text = tostring(option.value)
                            else
                                OptionInput.Text = tostring(option.default)
                            end
                        else
                            option.value = OptionInput.Text
                        end
                        
                        if option.callback then
                            option.callback(option.value)
                        end
                    end
                end)
            end
        end

        -- Tornar o mini-menu arrastável
        local miniMenuDragging = false
        local miniMenuDragStart = nil
        local miniMenuStartPosition = nil

        MiniMenuTitle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                miniMenuDragging = true
                miniMenuDragStart = input.Position
                miniMenuStartPosition = MiniMenu.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and miniMenuDragging then
                local delta = input.Position - miniMenuDragStart
                MiniMenu.Position = UDim2.new(
                    miniMenuStartPosition.X.Scale,
                    miniMenuStartPosition.X.Offset + delta.X,
                    miniMenuStartPosition.Y.Scale,
                    miniMenuStartPosition.Y.Offset + delta.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                miniMenuDragging = false
            end
        end)

        return MiniMenu
    end

    -- Função para criar mini-menus específicos
    local function CreateESPMiniMenu()
        local espOptions = {
            BoxColor = {type = "color", default = Config.Colors.ESP.Box},
            BoxThickness = {type = "number", default = 1, min = 1, max = 5},
            TracerColor = {type = "color", default = Config.Colors.ESP.Skeleton},
            TracerThickness = {type = "number", default = 1, min = 1, max = 5},
            NameColor = {type = "color", default = Config.Colors.ESP.Name},
            NameSize = {type = "number", default = 14, min = 8, max = 24},
            MaxDistance = {type = "number", default = 1000, min = 100, max = 10000}
        }
        
        return CreateMiniMenu("ESP Settings", espOptions, UDim2.new(0.5, 200, 0.5, -125))
    end

    local function CreateAimbotMiniMenu()
        local aimbotOptions = {
            Smoothness = {type = "number", default = 1, min = 0.1, max = 10},
            FOV = {type = "number", default = 100, min = 10, max = 800},
            PredictionStrength = {type = "number", default = 1, min = 0, max = 5},
            MaxDistance = {type = "number", default = 1000, min = 100, max = 10000}
        }
        
        return CreateMiniMenu("Aimbot Settings", aimbotOptions, UDim2.new(0.5, 200, 0.5, -125))
    end

    -- Adicionar ao sistema de UI
    UI.Windows.MainFrame = MainFrame
    UI.CreateMiniMenu = CreateMiniMenu
    UI.CreateESPMiniMenu = CreateESPMiniMenu
    UI.CreateAimbotMiniMenu = CreateAimbotMiniMenu

    return ScreenGui
end

-- Inicializar Interface
local MainUI = CreateMainInterface()

-- Sistema ESP e Aimbot
local ESPSystem = {
    Enabled = false,
    Players = {},
    Settings = {
        BoxESP = true,
        TracerESP = true,
        NameESP = true,
        HealthESP = true,
        DistanceESP = true,
        SkeletonESP = true,
        ChamsESP = true,
        ItemESP = true,
        MaxDistance = 1000,
        TeamCheck = true,
        RefreshRate = 1/60,
        Colors = {
            Box = Color3.fromRGB(255, 0, 0),
            Tracer = Color3.fromRGB(255, 255, 255),
            Name = Color3.fromRGB(255, 255, 0),
            Health = Color3.fromRGB(0, 255, 0),
            Distance = Color3.fromRGB(255, 255, 255),
            Skeleton = Color3.fromRGB(255, 255, 255),
            Chams = Color3.fromRGB(255, 0, 0)
        },
        Transparency = {
            Box = 0.8,
            Tracer = 0.8,
            Name = 1,
            Health = 1,
            Distance = 1,
            Skeleton = 0.8,
            Chams = 0.5
        }
    }
}

local AimbotSystem = {
    Enabled = false,
    Target = nil,
    FOVCircle = nil,
    Settings = {
        TargetPart = "Head",
        TeamCheck = true,
        VisibilityCheck = true,
        Smoothness = 1,
        FOV = 400,
        MaxDistance = 1000,
        PredictionEnabled = true,
        PredictionAmount = 1,
        TriggerBot = false,
        TriggerDelay = 0,
        SilentAim = false,
        WallBangEnabled = false,
        AutoShoot = false,
        AutoReload = false,
        RecoilControl = true,
        AimAssist = true,
        AimAssistStrength = 0.5,
        ClosestPoint = true,
        MultiPoint = {
            Enabled = true,
            Points = {"Head", "UpperTorso", "LowerTorso"}
        }
    }
}

-- Funções Utilitárias
local function IsAlive(player)
    return player and player.Character and 
           player.Character:FindFirstChild("Humanoid") and 
           player.Character:FindFirstChild("HumanoidRootPart") and
           player.Character.Humanoid.Health > 0
end

local function IsTeammate(player)
    return ESPSystem.Settings.TeamCheck and player.Team == LocalPlayer.Team
end

local function IsVisible(position)
    local ray = Ray.new(camera.CFrame.Position, position - camera.CFrame.Position)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, camera})
    return not hit
end

local function GetDistanceFromCamera(position)
    return (position - camera.CFrame.Position).Magnitude
end

-- Sistema ESP
local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

local function CreateESPObject(player)
    return {
        Box = CreateDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Transparency = ESPSystem.Settings.Transparency.Box,
            Color = ESPSystem.Settings.Colors.Box,
            Visible = false
        }),
        Tracer = CreateDrawing("Line", {
            Thickness = 1,
            Transparency = ESPSystem.Settings.Transparency.Tracer,
            Color = ESPSystem.Settings.Colors.Tracer,
            Visible = false
        }),
        Name = CreateDrawing("Text", {
            Size = 14,
            Center = true,
            Outline = true,
            Transparency = ESPSystem.Settings.Transparency.Name,
            Color = ESPSystem.Settings.Colors.Name,
            Visible = false
        }),
        Distance = CreateDrawing("Text", {
            Size = 13,
            Center = true,
            Outline = true,
            Transparency = ESPSystem.Settings.Transparency.Distance,
            Color = ESPSystem.Settings.Colors.Distance,
            Visible = false
        }),
        HealthBar = CreateDrawing("Square", {
            Thickness = 1,
            Filled = true,
            Transparency = ESPSystem.Settings.Transparency.Health,
            Color = ESPSystem.Settings.Colors.Health,
            Visible = false
        }),
        HealthBarOutline = CreateDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Transparency = 1,
            Color = Color3.new(0, 0, 0),
            Visible = false
        }),
        Skeleton = {},
        Chams = Instance.new("Highlight")
    }
end

-- Criar pontos do esqueleto
local function CreateSkeletonPoints()
    local points = {}
    local connections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"}
    }
    
    for _, connection in pairs(connections) do
        points[connection[1] .. connection[2]] = CreateDrawing("Line", {
            Thickness = 1,
            Transparency = ESPSystem.Settings.Transparency.Skeleton,
            Color = ESPSystem.Settings.Colors.Skeleton,
            Visible = false
        })
    end
    
    return points
end

-- Atualização do ESP
local function UpdateESP()
    while ESPSystem.Enabled do
        for player, esp in pairs(ESPSystem.Players) do
            if IsAlive(player) and player ~= LocalPlayer then
                local character = player.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                local head = character:FindFirstChild("Head")
                
                if humanoidRootPart and humanoid and head then
                    local distance = GetDistanceFromCamera(humanoidRootPart.Position)
                    local isTeammate = IsTeammate(player)
                    local isVisible = IsVisible(humanoidRootPart.Position)
                    
                    if distance <= ESPSystem.Settings.MaxDistance and not isTeammate then
                        -- Atualizar posição da caixa
                        local rootPos, rootVis = camera:WorldToViewportPoint(humanoidRootPart.Position)
                        local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
                        
                        if rootVis then
                            local boxSize = Vector2.new(2000 / rootPos.Z, headPos.Y - legPos.Y)
                            local boxPosition = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                            
                            -- Box ESP
                            esp.Box.Size = boxSize
                            esp.Box.Position = boxPosition
                            esp.Box.Visible = ESPSystem.Settings.BoxESP
                            esp.Box.Color = isVisible and ESPSystem.Settings.Colors.Box or 
                                          ESPSystem.Settings.Colors.Box:Lerp(Color3.new(1, 1, 1), 0.5)
                            
                            -- Tracer ESP
                            esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            esp.Tracer.Visible = ESPSystem.Settings.TracerESP
                            
                            -- Name ESP
                            esp.Name.Position = Vector2.new(rootPos.X, boxPosition.Y - 16)
                            esp.Name.Text = string.format("%s", player.Name)
                            esp.Name.Visible = ESPSystem.Settings.NameESP
                            
                            -- Distance ESP
                            esp.Distance.Position = Vector2.new(rootPos.X, boxPosition.Y + boxSize.Y + 2)
                            esp.Distance.Text = string.format("[%d studs]", math.floor(distance))
                            esp.Distance.Visible = ESPSystem.Settings.DistanceESP
                            
                            -- Health ESP
                            local healthBarSize = Vector2.new(2, boxSize.Y)
                            local healthBarPos = Vector2.new(boxPosition.X - healthBarSize.X * 2, boxPosition.Y)
                            esp.HealthBarOutline.Size = Vector2.new(healthBarSize.X, boxSize.Y)
                            esp.HealthBarOutline.Position = healthBarPos
                            esp.HealthBarOutline.Visible = ESPSystem.Settings.HealthESP
                            
                            esp.HealthBar.Size = Vector2.new(healthBarSize.X, boxSize.Y * (humanoid.Health / humanoid.MaxHealth))
                            esp.HealthBar.Position = Vector2.new(healthBarPos.X, healthBarPos.Y + boxSize.Y * (1 - humanoid.Health / humanoid.MaxHealth))
                            esp.HealthBar.Color = Color3.fromRGB(255 - 255 * (humanoid.Health / humanoid.MaxHealth), 255 * (humanoid.Health / humanoid.MaxHealth), 0)
                            esp.HealthBar.Visible = ESPSystem.Settings.HealthESP
                            
                            -- Skeleton ESP
                            if ESPSystem.Settings.SkeletonESP then
                                for _, connection in pairs(connections) do
                                    local part1 = character:FindFirstChild(connection[1])
                                    local part2 = character:FindFirstChild(connection[2])
                                    
                                    if part1 and part2 then
                                        local pos1 = camera:WorldToViewportPoint(part1.Position)
                                        local pos2 = camera:WorldToViewportPoint(part2.Position)
                                        
                                        local line = esp.Skeleton[connection[1] .. connection[2]]
                                        line.From = Vector2.new(pos1.X, pos1.Y)
                                        line.To = Vector2.new(pos2.X, pos2.Y)
                                        line.Visible = true
                                    end
                                end
                            end
                            
                            -- Chams ESP
                            if ESPSystem.Settings.ChamsESP then
                                esp.Chams.FillColor = ESPSystem.Settings.Colors.Chams
                                esp.Chams.FillTransparency = ESPSystem.Settings.Transparency.Chams
                                esp.Chams.OutlineColor = ESPSystem.Settings.Colors.Chams:Lerp(Color3.new(1, 1, 1), 0.5)
                                esp.Chams.OutlineTransparency = ESPSystem.Settings.Transparency.Chams + 0.1
                                esp.Chams.Adornee = character
                                esp.Chams.Parent = character
                            else
                                esp.Chams.Parent = nil
                            end
                        else
                            -- Ocultar ESP quando fora da tela
                            for _, drawing in pairs(esp) do
                                if typeof(drawing) == "table" then
                                    for _, line in pairs(drawing) do
                                        line.Visible = false
                                    end
                                elseif drawing:IsA("Highlight") then
                                    drawing.Parent = nil
                                else
                                    drawing.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
        RunService.RenderStepped:Wait()
    end
end

-- Sistema Aimbot
local function CreateFOVCircle()
    AimbotSystem.FOVCircle = CreateDrawing("Circle", {
        Thickness = 1,
        Color = Color3.new(1, 1, 1),
        Transparency = 0.7,
        Filled = false,
        Visible = true
    })
end

local function UpdateFOVCircle()
    if AimbotSystem.FOVCircle then
        AimbotSystem.FOVCircle.Radius = AimbotSystem.Settings.FOV
        AimbotSystem.FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end
end

local function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = AimbotSystem.Settings.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) and not IsTeammate(player) then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local targetPart = character:FindFirstChild(AimbotSystem.Settings.TargetPart)
            
            if targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    
                    if distance < shortestDistance then
                        if AimbotSystem.Settings.VisibilityCheck and not IsVisible(targetPart.Position) then
                            continue
                        end
                        
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Atualização do Aimbot
local function UpdateAimbot()
    while AimbotSystem.Enabled do
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetClosestPlayerToMouse()
            if target and target.Character then
                local targetPart = target.Character:FindFirstChild(AimbotSystem.Settings.TargetPart)
                if targetPart then
                    local targetPos = targetPart.Position
                    
                    -- Predição de movimento
                    if AimbotSystem.Settings.PredictionEnabled then
                        local velocity = targetPart.Velocity
                        targetPos = targetPos + (velocity * AimbotSystem.Settings.PredictionAmount)
                    end
                    
                    -- Conversão para coordenadas da tela
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                    
                    if onScreen then
                        -- Movimento suave da câmera
                        local mousePos = Vector2.new(mouse.X, mouse.Y)
                        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                        local delta = (targetScreenPos - mousePos) * AimbotSystem.Settings.Smoothness
                        
                        mousemoverel(delta.X, delta.Y)
                        
                        -- Auto disparo
                        if AimbotSystem.Settings.AutoShoot then
                            mouse1click()
                        end
                    end
                end
            end
        end
        
        UpdateFOVCircle()
        RunService.RenderStepped:Wait()
    end
end

-- Inicialização
local function Initialize()
    CreateFOVCircle()
    
    -- Gerenciar jogadores
    Players.PlayerAdded:Connect(function(player)
        ESPSystem.Players[player] = CreateESPObject(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        local esp = ESPSystem.Players[player]
        if esp then
            for _, drawing in pairs(esp) do
                if typeof(drawing) == "table" then
                    for _, line in pairs(drawing) do
                        line:Remove()
                    end
                elseif drawing:IsA("Highlight") then
                    drawing:Destroy()
                else
                    drawing:Remove()
                end
            end
            ESPSystem.Players[player] = nil
        end
    end)
    
    -- Iniciar sistemas
    spawn(UpdateESP)
    spawn(UpdateAimbot)
end

Initialize()

-- Sistemas Utilitários e Complementares
local UtilitySystem = {
    Movement = {
        SpeedHack = {
            Enabled = false,
            Speed = 2,
            Type = "CFrame" -- CFrame, Velocity, or WalkSpeed
        },
        InfiniteJump = {
            Enabled = false,
            Height = 50
        },
        NoClip = {
            Enabled = false,
            BypassMethod = "CFrame" -- CFrame or CanCollide
        },
        FlyHack = {
            Enabled = false,
            Speed = 2,
            Type = "CFrame" -- CFrame or BodyVelocity
        }
    },
    Combat = {
        NoRecoil = {
            Enabled = false,
            Intensity = 1
        },
        RapidFire = {
            Enabled = false,
            FireRate = 0.1
        },
        AutoReload = {
            Enabled = false,
            Delay = 0.1
        }
    },
    Visuals = {
        FullBright = {
            Enabled = false,
            Brightness = 2
        },
        NoFog = {
            Enabled = false
        },
        CustomSkybox = {
            Enabled = false,
            SkyboxID = "rbxassetid://123456"
        }
    },
    Misc = {
        AutoFarm = {
            Enabled = false,
            Range = 10
        },
        AntiAFK = {
            Enabled = false,
            Method = "Virtual" -- Virtual or Physical
        },
        ChatSpam = {
            Enabled = false,
            Messages = {},
            Delay = 1
        }
    }
}

-- Sistema de Movimento Avançado
local MovementSystem = {
    Initialize = function()
        -- SpeedHack
        local function UpdateSpeedHack()
            while UtilitySystem.Movement.SpeedHack.Enabled do
                if IsAlive(LocalPlayer) then
                    local character = LocalPlayer.Character
                    local humanoid = character:FindFirstChild("Humanoid")
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and hrp then
                        local moveDirection = humanoid.MoveDirection
                        if moveDirection.Magnitude > 0 then
                            if UtilitySystem.Movement.SpeedHack.Type == "CFrame" then
                                hrp.CFrame = hrp.CFrame + (moveDirection * UtilitySystem.Movement.SpeedHack.Speed)
                            elseif UtilitySystem.Movement.SpeedHack.Type == "Velocity" then
                                hrp.Velocity = moveDirection * (UtilitySystem.Movement.SpeedHack.Speed * 30)
                            else
                                humanoid.WalkSpeed = 16 * UtilitySystem.Movement.SpeedHack.Speed
                            end
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end

        -- NoClip
        local function UpdateNoClip()
            while UtilitySystem.Movement.NoClip.Enabled do
                if IsAlive(LocalPlayer) then
                    local character = LocalPlayer.Character
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if UtilitySystem.Movement.NoClip.BypassMethod == "CFrame" then
                                part.CanCollide = false
                            else
                                part.CanCollide = false
                            end
                        end
                    end
                end
                RunService.Stepped:Wait()
            end
        end

        -- FlyHack
        local function UpdateFlyHack()
            local flyPart = nil
            local bodyVelocity = nil
            
            while UtilitySystem.Movement.FlyHack.Enabled do
                if IsAlive(LocalPlayer) then
                    local character = LocalPlayer.Character
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        if UtilitySystem.Movement.FlyHack.Type == "BodyVelocity" then
                            if not bodyVelocity then
                                bodyVelocity = Instance.new("BodyVelocity")
                                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bodyVelocity.Parent = hrp
                            end
                            
                            local moveDirection = Vector3.new(
                                UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0,
                                UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 0,
                                UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0
                            )
                            
                            bodyVelocity.Velocity = CFrame.new(Vector3.new(), camera.CFrame.LookVector):VectorToWorldSpace(moveDirection * (UtilitySystem.Movement.FlyHack.Speed * 30))
                        else
                            local moveDirection = Vector3.new(
                                UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0,
                                UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 0,
                                UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0
                            )
                            
                            hrp.CFrame = hrp.CFrame * CFrame.new(moveDirection * UtilitySystem.Movement.FlyHack.Speed)
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
            
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
        end

        -- Infinite Jump
        UserInputService.JumpRequest:Connect(function()
            if UtilitySystem.Movement.InfiniteJump.Enabled and IsAlive(LocalPlayer) then
                local character = LocalPlayer.Character
                local humanoid = character:FindFirstChild("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and hrp then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, UtilitySystem.Movement.InfiniteJump.Height, hrp.Velocity.Z)
                end
            end
        end)

        -- Iniciar loops
        spawn(UpdateSpeedHack)
        spawn(UpdateNoClip)
        spawn(UpdateFlyHack)
    end
}

-- Sistema de Combate Avançado
local CombatSystem = {
    Initialize = function()
        -- NoRecoil
        local function HandleRecoil(weapon)
            if UtilitySystem.Combat.NoRecoil.Enabled then
                local mt = getrawmetatable(game)
                local oldNamecall = mt.__namecall
                setreadonly(mt, false)
                
                mt.__namecall = newcclosure(function(self, ...)
                    local args = {...}
                    local method = getnamecallmethod()
                    
                    if method == "FireServer" and string.find(self.Name, "Recoil") then
                        args[1] = args[1] * (1 - UtilitySystem.Combat.NoRecoil.Intensity)
                        return oldNamecall(self, unpack(args))
                    end
                    
                    return oldNamecall(self, ...)
                end)
                
                setreadonly(mt, true)
            end
        end

        -- RapidFire
        local function HandleRapidFire(weapon)
            if UtilitySystem.Combat.RapidFire.Enabled then
                local mt = getrawmetatable(game)
                local oldNamecall = mt.__namecall
                setreadonly(mt, false)
                
                mt.__namecall = newcclosure(function(self, ...)
                    local args = {...}
                    local method = getnamecallmethod()
                    
                    if method == "FireServer" and string.find(self.Name, "Fire") then
                        spawn(function()
                            wait(UtilitySystem.Combat.RapidFire.FireRate)
                            oldNamecall(self, unpack(args))
                        end)
                    end
                    
                    return oldNamecall(self, ...)
                end)
                
                setreadonly(mt, true)
            end
        end

        -- AutoReload
        local function HandleAutoReload(weapon)
            if UtilitySystem.Combat.AutoReload.Enabled then
                spawn(function()
                    while UtilitySystem.Combat.AutoReload.Enabled do
                        if weapon and weapon:FindFirstChild("Ammo") and weapon.Ammo.Value <= 0 then
                            weapon.Reload:FireServer()
                            wait(UtilitySystem.Combat.AutoReload.Delay)
                        end
                        wait(0.1)
                    end
                end)
            end
        end

        -- Observer de armas
        LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                HandleRecoil(child)
                HandleRapidFire(child)
                HandleAutoReload(child)
            end
        end)
    end
}

-- Sistema Visual Avançado
local VisualsSystem = {
    Initialize = function()
        -- FullBright
        local function UpdateFullBright()
            local lighting = game:GetService("Lighting")
            local oldAmbient = lighting.Ambient
            local oldBrightness = lighting.Brightness
            local oldClockTime = lighting.ClockTime
            local oldFogEnd = lighting.FogEnd
            local oldGlobalShadows = lighting.GlobalShadows
            
            while UtilitySystem.Visuals.FullBright.Enabled do
                lighting.Ambient = Color3.new(1, 1, 1)
                lighting.Brightness = UtilitySystem.Visuals.FullBright.Brightness
                lighting.ClockTime = 14
                lighting.FogEnd = 100000
                lighting.GlobalShadows = false
                RunService.RenderStepped:Wait()
            end
            
            lighting.Ambient = oldAmbient
            lighting.Brightness = oldBrightness
            lighting.ClockTime = oldClockTime
            lighting.FogEnd = oldFogEnd
            lighting.GlobalShadows = oldGlobalShadows
        end

        -- NoFog
        local function UpdateNoFog()
            local lighting = game:GetService("Lighting")
            local oldFogEnd = lighting.FogEnd
            local oldFogStart = lighting.FogStart
            
            while UtilitySystem.Visuals.NoFog.Enabled do
                lighting.FogEnd = 100000
                lighting.FogStart = 100000
                RunService.RenderStepped:Wait()
            end
            
            lighting.FogEnd = oldFogEnd
            lighting.FogStart = oldFogStart
        end

        -- CustomSkybox
        local function UpdateSkybox()
            local lighting = game:GetService("Lighting")
            local oldSkybox = lighting:FindFirstChildOfClass("Sky")
            
            if UtilitySystem.Visuals.CustomSkybox.Enabled then
                if oldSkybox then
                    oldSkybox:Destroy()
                end
                
                local sky = Instance.new("Sky")
                sky.SkyboxBk = UtilitySystem.Visuals.CustomSkybox.SkyboxID
                sky.SkyboxDn = UtilitySystem.Visuals.CustomSkybox.SkyboxID
                sky.SkyboxFt = UtilitySystem.Visuals.CustomSkybox.SkyboxID
                sky.SkyboxLf = UtilitySystem.Visuals.CustomSkybox.SkyboxID
                sky.SkyboxRt = UtilitySystem.Visuals.CustomSkybox.SkyboxID
                sky.SkyboxUp = UtilitySystem.Visuals.CustomSkybox.SkyboxID
                sky.Parent = lighting
            elseif oldSkybox then
                oldSkybox:Destroy()
            end
        end

        -- Iniciar loops
        spawn(UpdateFullBright)
        spawn(UpdateNoFog)
        spawn(UpdateSkybox)
    end
}

-- Sistema Misc Avançado
local MiscSystem = {
    Initialize = function()
        -- AutoFarm
        local function UpdateAutoFarm()
            while UtilitySystem.Misc.AutoFarm.Enabled do
                if IsAlive(LocalPlayer) then
                    local character = LocalPlayer.Character
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and v.Name == "Collect" then
                                local distance = (v.Position - hrp.Position).Magnitude
                                if distance <= UtilitySystem.Misc.AutoFarm.Range then
                                    hrp.CFrame = v.CFrame
                                    wait(0.1)
                                end
                            end
                        end
                    end
                end
                wait(0.1)
            end
        end

        -- AntiAFK
        local function UpdateAntiAFK()
            local virtualUser = game:GetService("VirtualUser")
            local lastActivity = tick()
            
            UserInputService.WindowFocused:Connect(function()
                lastActivity = tick()
            end)
            
            while UtilitySystem.Misc.AntiAFK.Enabled do
                if tick() - lastActivity >= 10 then
                    if UtilitySystem.Misc.AntiAFK.Method == "Virtual" then
                        virtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        wait(0.1)
                        virtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    else
                        keypress(0x20) -- Espaço
                        wait(0.1)
                        keyrelease(0x20)
                    end
                    lastActivity = tick()
                end
                wait(1)
            end
        end

        -- ChatSpam
        local function UpdateChatSpam()
            while UtilitySystem.Misc.ChatSpam.Enabled do
                if #UtilitySystem.Misc.ChatSpam.Messages > 0 then
                    local message = UtilitySystem.Misc.ChatSpam.Messages[math.random(1, #UtilitySystem.Misc.ChatSpam.Messages)]
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
                    wait(UtilitySystem.Misc.ChatSpam.Delay)
                end
                wait(0.1)
            end
        end

        -- Iniciar loops
        spawn(UpdateAutoFarm)
        spawn(UpdateAntiAFK)
        spawn(UpdateChatSpam)
    end
}

-- Inicialização dos Sistemas
local function InitializeUtilitySystems()
    MovementSystem.Initialize()
    CombatSystem.Initialize()
    VisualsSystem.Initialize()
    MiscSystem.Initialize()
end

InitializeUtilitySystems()

-- Sistema de Integração Final e Segurança Avançada
local IntegrationSystem = {
    SecurityChecks = {
        LastCheck = 0,
        CheckInterval = 1,
        DetectionCount = 0,
        MaxDetections = 3,
        Enabled = true
    },
    
    MemoryProtection = {
        Variables = {},
        Functions = {},
        Hooks = {}
    },
    
    NetworkSecurity = {
        BlockedEvents = {},
        SafeEvents = {},
        LastNetworkCheck = 0
    }
}

-- Sistema de Proteção de Memória Avançado
local MemoryProtectionSystem = {
    Initialize = function()
        -- Proteção de Variáveis
        local function ProtectVariable(name, value)
            local encryptedName = SecuritySystem.Encrypt(name)
            local encryptedValue = SecuritySystem.Encrypt(tostring(value))
            
            IntegrationSystem.MemoryProtection.Variables[encryptedName] = encryptedValue
            
            return setmetatable({}, {
                __index = function(_, k)
                    if SecuritySystem.Decrypt(encryptedName) == k then
                        return SecuritySystem.Decrypt(encryptedValue)
                    end
                end,
                
                __newindex = function(_, k, v)
                    if SecuritySystem.Decrypt(encryptedName) == k then
                        IntegrationSystem.MemoryProtection.Variables[encryptedName] = SecuritySystem.Encrypt(tostring(v))
                    end
                end
            })
        end

        -- Proteção de Funções
        local function ProtectFunction(func)
            local encryptedFunc = SecuritySystem.Encrypt(string.dump(func))
            
            return function(...)
                local decryptedFunc = SecuritySystem.Decrypt(encryptedFunc)
                local loadedFunc = loadstring(decryptedFunc)
                return loadedFunc(...)
            end
        end

        -- Aplicar proteções
        for name, value in pairs(getfenv(0)) do
            if type(value) == "function" then
                getfenv(0)[name] = ProtectFunction(value)
            else
                getfenv(0)[name] = ProtectVariable(name, value)
            end
        end
    end
}

-- Sistema de Segurança de Rede Avançado
local NetworkSecuritySystem = {
    Initialize = function()
        local function CreateSecureProxy(remote)
            local proxy = Instance.new(remote.ClassName)
            
            return setmetatable({}, {
                __index = function(_, k)
                    if k == "FireServer" then
                        return function(_, ...)
                            local args = {...}
                            
                            -- Verificação de argumentos suspeitos
                            for _, arg in pairs(args) do
                                if type(arg) == "string" then
                                    if string.find(string.lower(arg), "exploit") or
                                       string.find(string.lower(arg), "hack") or
                                       string.find(string.lower(arg), "cheat") then
                                        return
                                    end
                                end
                            end
                            
                            -- Verificação de frequência
                            if tick() - IntegrationSystem.NetworkSecurity.LastNetworkCheck < 0.1 then
                                return
                            end
                            
                            IntegrationSystem.NetworkSecurity.LastNetworkCheck = tick()
                            return remote:FireServer(...)
                        end
                    end
                    return remote[k]
                end
            })
        end

        -- Proteção de RemoteEvents
        for _, remote in pairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                remote = CreateSecureProxy(remote)
            end
        end
    end
}

-- Sistema de Verificação de Integridade
local IntegrityCheckSystem = {
    Initialize = function()
        local function PerformIntegrityCheck()
            while IntegrationSystem.SecurityChecks.Enabled do
                local currentTick = tick()
                
                if currentTick - IntegrationSystem.SecurityChecks.LastCheck >= IntegrationSystem.SecurityChecks.CheckInterval then
                    -- Verificar integridade da memória
                    for encryptedName, encryptedValue in pairs(IntegrationSystem.MemoryProtection.Variables) do
                        local decryptedName = SecuritySystem.Decrypt(encryptedName)
                        local decryptedValue = SecuritySystem.Decrypt(encryptedValue)
                        
                        if getfenv(0)[decryptedName] ~= decryptedValue then
                            IntegrationSystem.SecurityChecks.DetectionCount = IntegrationSystem.SecurityChecks.DetectionCount + 1
                        end
                    end
                    
                    -- Verificar hooks
                    local mt = getrawmetatable(game)
                    if mt.__namecall ~= IntegrationSystem.MemoryProtection.Hooks.NamecallHook then
                        IntegrationSystem.SecurityChecks.DetectionCount = IntegrationSystem.SecurityChecks.DetectionCount + 1
                    end
                    
                    -- Ação em caso de detecções
                    if IntegrationSystem.SecurityChecks.DetectionCount >= IntegrationSystem.SecurityChecks.MaxDetections then
                        SecuritySystem.TriggerProtection()
                    end
                    
                    IntegrationSystem.SecurityChecks.LastCheck = currentTick
                end
                
                wait(1)
            end
        end
        
        spawn(PerformIntegrityCheck)
    end
}

-- Sistema de Ofuscação Dinâmica
local ObfuscationSystem = {
    Initialize = function()
        local function ObfuscateString(str)
            local result = ""
            for i = 1, #str do
                result = result .. string.char(bit32.bxor(string.byte(str, i), 
                    string.byte(SecuritySystem.EncryptionKey, (i-1) % #SecuritySystem.EncryptionKey + 1)))
            end
            return result
        end

        local function ObfuscateTable(tbl)
            local result = {}
            for k, v in pairs(tbl) do
                local newKey = ObfuscateString(tostring(k))
                local newValue = v
                
                if type(v) == "table" then
                    newValue = ObfuscateTable(v)
                elseif type(v) == "string" then
                    newValue = ObfuscateString(v)
                end
                
                result[newKey] = newValue
            end
            return result
        end

        -- Aplicar ofuscação aos sistemas
        ESPSystem = ObfuscateTable(ESPSystem)
        AimbotSystem = ObfuscateTable(AimbotSystem)
        UtilitySystem = ObfuscateTable(UtilitySystem)
    end
}

-- Sistema de Auto-Atualização
local UpdateSystem = {
    Initialize = function()
        local function CheckForUpdates()
            local success, result = pcall(function()
                -- Implementar lógica de verificação de atualizações aqui
                return true
            end)
            
            if success and result then
                -- Atualizar sistemas
                SecuritySystem.Initialize()
                MemoryProtectionSystem.Initialize()
                NetworkSecuritySystem.Initialize()
                IntegrityCheckSystem.Initialize()
                ObfuscationSystem.Initialize()
            end
        end
        
        spawn(function()
            while wait(3600) do -- Verificar atualizações a cada hora
                CheckForUpdates()
            end
        end)
    end
}

-- Sistema de Recuperação
local RecoverySystem = {
    Initialize = function()
        local function CreateBackup()
            local backup = {
                ESP = ESPSystem,
                Aimbot = AimbotSystem,
                Utility = UtilitySystem,
                Security = SecuritySystem
            }
            
            local encryptedBackup = SecuritySystem.Encrypt(HttpService:JSONEncode(backup))
            writefile("TestHub/backup_" .. os.time() .. ".dat", encryptedBackup)
        end

        local function RestoreFromBackup()
            local backups = {}
            for _, file in pairs(listfiles("TestHub")) do
                if string.match(file, "backup_%d+.dat") then
                    table.insert(backups, file)
                end
            end
            
            if #backups > 0 then
                table.sort(backups, function(a, b)
                    local timeA = tonumber(string.match(a, "%d+"))
                    local timeB = tonumber(string.match(b, "%d+"))
                    return timeA > timeB
                end)
                
                local data = readfile(backups[1])
                local decrypted = SecuritySystem.Decrypt(data)
                local backup = HttpService:JSONDecode(decrypted)
                
                ESPSystem = backup.ESP
                AimbotSystem = backup.Aimbot
                UtilitySystem = backup.Utility
                SecuritySystem = backup.Security
            end
        end

        -- Criar backup a cada 30 minutos
        spawn(function()
            while wait(1800) do
                CreateBackup()
            end
        end)

        -- Tentar recuperar em caso de falha
        game:GetService("ScriptContext").Error:Connect(function()
            pcall(RestoreFromBackup)
        end)
    end
}

-- Inicialização Final
local function InitializeAll()
    SecuritySystem.Initialize()
    MemoryProtectionSystem.Initialize()
    NetworkSecuritySystem.Initialize()
    IntegrityCheckSystem.Initialize()
    ObfuscationSystem.Initialize()
    UpdateSystem.Initialize()
    RecoverySystem.Initialize()
    
    -- Conectar todos os sistemas
    ESPSystem.SecuritySystem = SecuritySystem
    AimbotSystem.SecuritySystem = SecuritySystem
    UtilitySystem.SecuritySystem = SecuritySystem
    
    -- Iniciar loop principal
    spawn(function()
        while wait() do
            if not IntegrationSystem.SecurityChecks.Enabled then
                break
            end
            
            -- Manter sistemas ativos
            for _, system in pairs({ESPSystem, AimbotSystem, UtilitySystem}) do
                if system.Enabled then
                    system:Update()
                end
            end
        end
    end)
end

-- Iniciar tudo
InitializeAll()
