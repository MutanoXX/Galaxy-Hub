local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local dbFile = "dungeon_data.json"

-- Função para salvar dados no banco de dados
local function saveToDatabase(data, isActive)
    local dbData = {
        initialData = data,
        isActive = isActive,
        lastUpdated = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    local success, result = pcall(function()
        writefile(dbFile, HttpService:JSONEncode(dbData))
    end)
    if success then
        print("Dados salvos em " .. dbFile)
    else
        warn("Erro ao salvar dados no banco de dados: " .. tostring(result))
    end
end

-- Função para carregar dados do banco de dados
local function loadFromDatabase()
    local success, result = pcall(function()
        if isfile(dbFile) then
            return HttpService:JSONDecode(readfile(dbFile))
        end
        return nil
    end)
    if success and result then
        print("Dados carregados do banco de dados")
        return result
    else
        print("Nenhum banco de dados encontrado, criando novo")
        return nil
    end
end

-- Função para esperar o carregamento do servidor da dungeon
local function waitForDungeonLoad()
    local timeout = 30 -- segundos
    local startTime = tick()
    while tick() - startTime < timeout do
        if game.Workspace:FindFirstChild("Dungeon") or Players.LocalPlayer.PlayerGui:FindFirstChild("DungeonUI") then
            return true
        end
        wait(0.5)
    end
    print("Timeout ao esperar o carregamento da dungeon")
    return false
end

-- Função para encontrar o portal da dungeon com múltiplos métodos
local function findDungeonPortal()
    local methods = {
        -- Método 1: Busca por objetos com atributos "Island", "Rank", "Type"
        {
            func = function()
                for _, obj in ipairs(game.Workspace:GetDescendants()) do
                    if obj:GetAttribute("Island") and obj:GetAttribute("Rank") and obj:GetAttribute("Type") then
                        return obj, "Atributos Island/Rank/Type"
                    end
                end
                return nil, nil
            end,
            name = "Método 1"
        },
        -- Método 2: Busca por nomes como "Portal", "DungeonPortal", "Gate", "Spawn"
        {
            func = function()
                local keywords = {"portal", "dungeonportal", "gate", "spawn"}
                for _, obj in ipairs(game.Workspace:GetDescendants()) do
                    for _, keyword in ipairs(keywords) do
                        if obj.Name:lower():match(keyword) then
                            return obj, "Nome contendo " .. keyword
                        end
                    end
                end
                return nil, nil
            end,
            name = "Método 2"
        },
        -- Método 3: Busca em ReplicatedStorage por pastas ou valores
        {
            func = function()
                local dungeonFolder = ReplicatedStorage:FindFirstChild("Dungeons") or ReplicatedStorage:FindFirstChild("DungeonData")
                if dungeonFolder then
                    for _, obj in ipairs(dungeonFolder:GetDescendants()) do
                        if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:GetAttribute("Island") then
                            return obj, "ReplicatedStorage Dungeons/Data"
                        end
                    end
                end
                return nil, nil
            end,
            name = "Método 3"
        },
        -- Método 4: Busca em pastas de ilhas
        {
            func = function()
                local islandFolders = {"Leveling Island", "Grass Village", "Brum Island", "Main Island"}
                for _, folderName in ipairs(islandFolders) do
                    local folder = game.Workspace:FindFirstChild(folderName)
                    if folder then
                        for _, obj in ipairs(folder:GetDescendants()) do
                            if obj.Name:lower():match("portal") or obj:GetAttribute("Island") then
                                return obj, "Pasta de ilha " .. folderName
                            end
                        end
                    end
                end
                return nil, nil
            end,
            name = "Método 4"
        },
        -- Método 5: Busca por atributos alternativos
        {
            func = function()
                for _, obj in ipairs(game.Workspace:GetDescendants()) do
                    if obj:GetAttribute("Location") or obj:GetAttribute("Difficulty") then
                        return obj, "Atributos Location/Difficulty"
                    end
                end
                return nil, nil
            end,
            name = "Método 5"
        },
        -- Método 6: Busca por eventos remotos
        {
            func = function()
                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") and obj.Name:lower():match("dungeon") then
                        return obj, "Evento remoto Dungeon"
                    end
                end
                return nil, nil
            end,
            name = "Método 6"
        },
        -- Método 7: Busca por objetos com atributos genéricos
        {
            func = function()
                for _, obj in ipairs(game.Workspace:GetDescendants()) do
                    if obj:GetAttributes() and next(obj:GetAttributes()) then
                        for attr, _ in pairs(obj:GetAttributes()) do
                            if attr:lower():match("dungeon") or attr:lower():match("island") then
                                return obj, "Atributo genérico " .. attr
                            end
                        end
                    end
                end
                return nil, nil
            end,
            name = "Método 7"
        }
    }

    for _, method in ipairs(methods) do
        local portal, methodDetail = method.func()
        if portal then
            print(method.name .. " encontrou portal: " .. portal.Name .. " (" .. (methodDetail or "Sem detalhes") .. ")")
            return portal, method.name .. " - " .. (methodDetail or "Sem detalhes")
        end
    end
    print("Nenhum portal encontrado após tentar todos os métodos")
    return nil, nil
end

-- Função para coletar dados iniciais (antes do teleporte)
local function getInitialDungeonData()
    local dungeonData = {
        island = "Unknown",
        name = "Unknown",
        type = "Unknown",
        rank = "Unknown",
        status = "Not Spawned",
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        serverJobId = game.JobId or "Unknown",
        methodUsed = "Nenhum"
    }

    local portal, methodDetail = findDungeonPortal()
    if portal then
        local success, result = pcall(function()
            dungeonData.island = portal:GetAttribute("Island") or portal:GetAttribute("Location") or portal.Parent.Name or "Unknown"
            dungeonData.name = portal:GetAttribute("Name") or portal.Name or dungeonData.name
            dungeonData.type = portal:GetAttribute("Type") or portal:GetAttribute("DungeonType") or "Normal"
            dungeonData.rank = portal:GetAttribute("Rank") or portal:GetAttribute("Difficulty") or "C"
            dungeonData.status = "Spawned"
            dungeonData.methodUsed = methodDetail or "Desconhecido"
        end)
        if not success then
            warn("Erro ao acessar dados do portal: " .. tostring(result))
        end
    end

    print("Dados Iniciais: Island=" .. dungeonData.island .. ", Name=" .. dungeonData.name .. ", Type=" .. dungeonData.type .. ", Rank=" .. dungeonData.rank .. ", Método=" .. dungeonData.methodUsed)
    saveToDatabase(dungeonData, true) -- Salvar dados iniciais e estado ativo
    return dungeonData
end

-- Função para coletar dados completos (após teleporte)
local function getFullDungeonData(initialIsland)
    local dungeonData = {
        name = "Unknown",
        type = "Unknown",
        rank = "Unknown",
        status = "Active",
        island = initialIsland or "Unknown",
        totalRooms = 0,
        currentRoom = 0,
        roomDisplay = "Room: 0/0",
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        serverJobId = game.JobId or "Unknown",
        methodUsed = "Nenhum"
    }

    local methods = {
        -- Método 1: Atributos do objeto Dungeon
        {
            func = function()
                local dungeonObj = game.Workspace:FindFirstChild("Dungeon")
                if dungeonObj then
                    dungeonData.name = dungeonObj:GetAttribute("Name") or dungeonObj.Name or dungeonData.name
                    dungeonData.type = dungeonObj:GetAttribute("Type") or dungeonObj:GetAttribute("DungeonType") or "Normal"
                    dungeonData.rank = dungeonObj:GetAttribute("Rank") or dungeonObj:GetAttribute("Difficulty") or "C"
                    dungeonData.totalRooms = dungeonObj:GetAttribute("TotalRooms") or 0
                    dungeonData.currentRoom = dungeonObj:GetAttribute("CurrentRoom") or 0
                    dungeonData.roomDisplay = "Room: " .. dungeonData.currentRoom .. "/" .. dungeonData.totalRooms
                    return true, "Atributos TotalRooms/CurrentRoom"
                end
                return false, nil
            end,
            name = "Método 1"
        },
        -- Método 2: PlayerGui TextLabel
        {
            func = function()
                local playerGui = Players.LocalPlayer.PlayerGui
                for _, gui in ipairs(playerGui:GetDescendants()) do
                    if gui:IsA("TextLabel") and gui.Text:match("Room:%s*%d+/%d+") then
                        dungeonData.roomDisplay = gui.Text
                        local current, total = gui.Text:match("Room:%s*(%d+)/(%d+)")
                        dungeonData.currentRoom = tonumber(current) or dungeonData.currentRoom
                        dungeonData.totalRooms = tonumber(total) or dungeonData.totalRooms
                        return true, "TextLabel Room: X/Y"
                    end
                end
                return false, nil
            end,
            name = "Método 2"
        },
        -- Método 3: Objetos Room/Stage
        {
            func = function()
                for _, obj in ipairs(game.Workspace:GetDescendants()) do
                    if obj:GetAttribute("RoomNumber") or obj:GetAttribute("Stage") or obj.Name:lower():match("room") or obj.Name:lower():match("stage") then
                        dungeonData.currentRoom = obj:GetAttribute("RoomNumber") or obj:GetAttribute("Stage") or dungeonData.currentRoom
                        dungeonData.totalRooms = obj:GetAttribute("TotalRooms") or obj:GetAttribute("TotalStages") or dungeonData.totalRooms
                        dungeonData.roomDisplay = "Room: " .. dungeonData.currentRoom .. "/" .. dungeonData.totalRooms
                        return true, "Objeto RoomNumber/Stage"
                    end
                end
                return false, nil
            end,
            name = "Método 3"
        },
        -- Método 4: Atributos alternativos
        {
            func = function()
                for _, obj in ipairs(game.Workspace:GetDescendants()) do
                    if obj:GetAttribute("CurrentStage") or obj:GetAttribute("MaxRooms") then
                        dungeonData.currentRoom = obj:GetAttribute("CurrentStage") or dungeonData.currentRoom
                        dungeonData.totalRooms = obj:GetAttribute("MaxRooms") or dungeonData.totalRooms
                        dungeonData.roomDisplay = "Room: " .. dungeonData.currentRoom .. "/" .. dungeonData.totalRooms
                        return true, "Atributos CurrentStage/MaxRooms"
                    end
                end
                return false, nil
            end,
            name = "Método 4"
        },
        -- Método 5: Busca por objetos com atributos genéricos
        {
            func = function()
                for _, obj in ipairs(game.Workspace:GetDescendants()) do
                    if obj:GetAttributes() and next(obj:GetAttributes()) then
                        for attr, _ in pairs(obj:GetAttributes()) do
                            if attr:lower():match("room") or attr:lower():match("stage") then
                                dungeonData.currentRoom = obj:GetAttribute(attr) or dungeonData.currentRoom
                                dungeonData.totalRooms = obj:GetAttribute("Total" .. attr) or dungeonData.totalRooms
                                dungeonData.roomDisplay = "Room: " .. dungeonData.currentRoom .. "/" .. dungeonData.totalRooms
                                return true, "Atributo genérico " .. attr
                            end
                        end
                    end
                end
                return false, nil
            end,
            name = "Método 5"
        }
    }

    for _, method in ipairs(methods) do
        local success, methodDetail = method.func()
        if success then
            dungeonData.methodUsed = method.name .. " - " .. (methodDetail or "Sem detalhes")
            print(method.name .. " encontrou dados: " .. dungeonData.roomDisplay .. " (" .. methodDetail .. ")")
            break
        end
    end

    print("Dados Completos: Name=" .. dungeonData.name .. ", Rooms=" .. dungeonData.roomDisplay .. ", Island=" .. dungeonData.island .. ", Método=" .. dungeonData.methodUsed)
    return dungeonData
end

-- Função para criar o mini menu
local function createMiniMenu(initialData, fullData)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = Players.LocalPlayer.PlayerGui
    ScreenGui.Name = "DungeonNotifyMenu"

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 400)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.Active = true
    Frame.Draggable = true

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Text = "Galaxy-Notify-Arise"
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 18
    TitleLabel.Parent = Frame

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.Text = "-"
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = Frame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -10, 1, -40)
    ContentFrame.Position = UDim2.new(0, 5, 0, 35)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Frame

    local function updateContent()
        for _, child in ipairs(ContentFrame:GetChildren()) do
            child:Destroy()
        end

        local function addLabel(text, yOffset)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, yOffset)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.Text = text
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = ContentFrame
        end

        local yOffset = 0
        addLabel("Dados Iniciais:", yOffset)
        yOffset = yOffset + 20
        addLabel("  Ilha: " .. (initialData.island or "Unknown"), yOffset)
        yOffset = yOffset + 20
        addLabel("  Nome: " .. (initialData.name or "Unknown"), yOffset)
        yOffset = yOffset + 20
        addLabel("  Tipo: " .. (initialData.type or "Unknown"), yOffset)
        yOffset = yOffset + 20
        addLabel("  Rank: " .. (initialData.rank or "Unknown"), yOffset)
        yOffset = yOffset + 20
        addLabel("  Status: " .. (initialData.status or "Not Spawned"), yOffset)
        yOffset = yOffset + 20
        addLabel("  Método: " .. (initialData.methodUsed or "Nenhum"), yOffset)
        yOffset = yOffset + 20

        if fullData then
            addLabel("Dados Completos:", yOffset)
            yOffset = yOffset + 20
            addLabel("  Ilha: " .. (fullData.island or "Unknown"), yOffset)
            yOffset = yOffset + 20
            addLabel("  Nome: " .. (fullData.name or "Unknown"), yOffset)
            yOffset = yOffset + 20
            addLabel("  Tipo: " .. (fullData.type or "Unknown"), yOffset)
            yOffset = yOffset + 20
            addLabel("  Rank: " .. (fullData.rank or "Unknown"), yOffset)
            yOffset = yOffset + 20
            addLabel("  Salas: " .. (fullData.roomDisplay or "Room: 0/0"), yOffset)
            yOffset = yOffset + 20
            addLabel("  Método: " .. (fullData.methodUsed or "Nenhum"), yOffset)
        end
    end

    updateContent()

    local isMinimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Frame.Size = UDim2.new(0, 300, 0, 30)
            MinimizeButton.Text = "+"
            ContentFrame.Visible = false
        else
            Frame.Size = UDim2.new(0, 300, 0, 400)
            MinimizeButton.Text = "-"
            ContentFrame.Visible = true
        end
    end)

    return updateContent
end

-- Execução principal
local db = loadFromDatabase()
local initialData = getInitialDungeonData()
local updateMenu = createMiniMenu(initialData, nil)

-- Verificar se estamos no servidor da dungeon
if db and db.isActive then
    print("Script já ativado, verificando servidor da dungeon")
    if waitForDungeonLoad() then
        local fullData = getFullDungeonData(initialData.island)
        updateMenu(initialData, fullData)
        saveToDatabase(initialData, false) -- Desativar estado após coletar dados completos
    end
else
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/JustLevel/goombahub/main/AriseCrossover.lua"))()
    end)
    if not success then
        warn("Erro ao executar loadstring: " .. tostring(result))
        saveToDatabase(initialData, false)
        return
    end

    wait(5)
    if waitForDungeonLoad() then
        local fullData = getFullDungeonData(initialData.island)
        updateMenu(initialData, fullData)
        saveToDatabase(initialData, false) -- Desativar estado após coletar dados completos
    end
end
