local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local webhookURL = "https://discord.com/api/webhooks/1347400165027217490/b0q6WACLsRPC_XjrNNNYXOKG-lRp9-vccdKxmlZE-wAMeraf5dZ5PQS0HWHd0THhp37V"
local proxyWebhookURL = "https://webhook.lewisakura.moe/api/webhooks/1347400165027217490/b0q6WACLsRPC_XjrNNNYXOKG-lRp9-vccdKxmlZE-wAMeraf5dZ5PQS0HWHd0THhp37V"

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
        function()
            for _, obj in ipairs(game.Workspace:GetDescendants()) do
                if obj:GetAttribute("Island") and obj:GetAttribute("Rank") and obj:GetAttribute("Type") then
                    print("Portal encontrado via atributos: " .. obj.Name)
                    return obj
                end
            end
            return nil
        end,
        -- Método 2: Busca por objetos com nome contendo "Portal" ou "DungeonPortal"
        function()
            for _, obj in ipairs(game.Workspace:GetDescendants()) do
                if obj.Name:lower():match("portal") or obj.Name:lower():match("dungeon") then
                    print("Portal encontrado via nome: " .. obj.Name)
                    return obj
                end
            end
            return nil
        end,
        -- Método 3: Busca em ReplicatedStorage por pastas ou valores de dungeon
        function()
            local dungeonFolder = ReplicatedStorage:FindFirstChild("Dungeons") or ReplicatedStorage:FindFirstChild("DungeonData")
            if dungeonFolder then
                for _, obj in ipairs(dungeonFolder:GetDescendants()) do
                    if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:GetAttribute("Island") then
                        print("Portal encontrado via ReplicatedStorage: " .. obj.Name)
                        return obj
                    end
                end
            end
            return nil
        end,
        -- Método 4: Busca por objetos em pastas de ilhas (ex.: Leveling Island)
        function()
            local islandFolders = {"Leveling Island", "Grass Village", "Brum Island"}
            for _, folderName in ipairs(islandFolders) do
                local folder = game.Workspace:FindFirstChild(folderName)
                if folder then
                    for _, obj in ipairs(folder:GetDescendants()) do
                        if obj.Name:lower():match("portal") or obj:GetAttribute("Island") then
                            print("Portal encontrado em pasta de ilha: " .. obj.Name .. " em " .. folderName)
                            return obj
                        end
                    end
                end
            end
            return nil
        end
    }

    for i, method in ipairs(methods) do
        local portal = method()
        if portal then
            print("Método " .. i .. " encontrou portal: " .. portal.Name)
            return portal
        end
    end
    print("Nenhum portal encontrado")
    return nil
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
        serverJobId = game.JobId or "Unknown"
    }

    local portal = findDungeonPortal()
    if portal then
        local success, result = pcall(function()
            dungeonData.island = portal:GetAttribute("Island") or portal.Parent.Name or "Unknown"
            dungeonData.name = portal:GetAttribute("Name") or portal.Name or dungeonData.name
            dungeonData.type = portal:GetAttribute("Type") or portal:GetAttribute("DungeonType") or "Normal"
            dungeonData.rank = portal:GetAttribute("Rank") or portal:GetAttribute("Difficulty") or "C"
            dungeonData.status = "Spawned"
        end)
        if not success then
            warn("Erro ao acessar dados do portal: " .. tostring(result))
        end
    end

    print("Dados Iniciais: Island=" .. dungeonData.island .. ", Name=" .. dungeonData.name .. ", Type=" .. dungeonData.type .. ", Rank=" .. dungeonData.rank)
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
        serverJobId = game.JobId or "Unknown"
    }

    -- Método 1: Verificar atributos do objeto Dungeon
    local dungeonObj = game.Workspace:FindFirstChild("Dungeon")
    if dungeonObj then
        local success, result = pcall(function()
            dungeonData.name = dungeonObj:GetAttribute("Name") or dungeonObj.Name or dungeonData.name
            dungeonData.type = dungeonObj:GetAttribute("Type") or dungeonObj:GetAttribute("DungeonType") or "Normal"
            dungeonData.rank = dungeonObj:GetAttribute("Rank") or dungeonObj:GetAttribute("Difficulty") or "C"
            dungeonData.totalRooms = dungeonObj:GetAttribute("TotalRooms") or 0
            dungeonData.currentRoom = dungeonObj:GetAttribute("CurrentRoom") or 0
            dungeonData.roomDisplay = "Room: " .. dungeonData.currentRoom .. "/" .. dungeonData.totalRooms
        end)
        if not success then
            warn("Erro ao acessar dados da dungeon: " .. tostring(result))
        end
    end

    -- Método 2: Verificar PlayerGui para exibição de salas
    local playerGui = Players.LocalPlayer.PlayerGui
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Text:match("Room:%s*%d+/%d+") then
            local success, result = pcall(function()
                dungeonData.roomDisplay = gui.Text
                local current, total = gui.Text:match("Room:%s*(%d+)/(%d+)")
                dungeonData.currentRoom = tonumber(current) or dungeonData.currentRoom
                dungeonData.totalRooms = tonumber(total) or dungeonData.totalRooms
            end)
            if success then
                print("Salas encontradas via PlayerGui: " .. dungeonData.roomDisplay)
                break
            else
                warn("Erro ao parsear exibição de sala: " .. tostring(result))
            end
        end
    end

    -- Método 3: Busca por objetos com RoomNumber ou similar
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:GetAttribute("RoomNumber") or obj.Name:lower():match("room") then
            local success, result = pcall(function()
                dungeonData.currentRoom = obj:GetAttribute("RoomNumber") or dungeonData.currentRoom
                dungeonData.totalRooms = obj:GetAttribute("TotalRooms") or dungeonData.totalRooms
                dungeonData.roomDisplay = "Room: " .. dungeonData.currentRoom .. "/" .. dungeonData.totalRooms
            end)
            if success then
                print("Salas encontradas via objeto Room: " .. dungeonData.roomDisplay)
                break
            end
        end
    end

    print("Dados Completos: Name=" .. dungeonData.name .. ", Rooms=" .. dungeonData.roomDisplay .. ", Island=" .. dungeonData.island)
    return dungeonData
end

-- Função para criar e enviar o embed do Discord
local function sendWebhook(data, isInitial)
    local embed = {
        title = "Galaxy-Notify-Arise: Dungeon Report",
        description = isInitial and 
            ("**Spawn Location: " .. data.island .. "**\nDungeon detectada em AriseCrossover! 📡") or 
            ("**Spawn Location: " .. data.island .. "**\nAtividade em andamento na dungeon! 🌌"),
        color = 0x800080,
        fields = isInitial and {
            {name = "Nome da Dungeon", value = data.name, inline = true},
            {name = "Rank", value = data.rank, inline = true},
            {name = "Tipo", value = data.type, inline = true},
            {name = "Status", value = data.status, inline = true},
            {name = "ID do Servidor", value = data.serverJobId, inline = false}
        } or {
            {name = "Nome da Dungeon", value = data.name, inline = true},
            {name = "Rank", value = data.rank, inline = true},
            {name = "Tipo", value = data.type, inline = true},
            {name = "Status", value = data.status, inline = true},
            {name = "Salas", value = data.roomDisplay, inline = true},
            {name = "ID do Servidor", value = data.serverJobId, inline = false}
        },
        footer = {
            text = "Galaxy-Notify-Arise | Powered by xAI"
        },
        timestamp = data.timestamp
    }

    local payload = {
        embeds = {embed},
        content = isInitial and "🌌 Alerta de Spawn de Dungeon - Galaxy-Notify-Arise! 🌌" or "🌌 Atualização de Progresso na Dungeon - Galaxy-Notify-Arise! 🌌"
    }

    local urls = {webhookURL, proxyWebhookURL}
    for _, url in ipairs(urls) do
        local success, response = pcall(function()
            return HttpService:PostAsync(
                url,
                HttpService:JSONEncode(payload),
                Enum.HttpContentType.ApplicationJson
            )
        end)
        if success then
            print("Webhook enviado com sucesso para: " .. url)
            return
        else
            warn("Erro ao enviar webhook para " .. url .. ": " .. tostring(response))
        end
    end
end

-- Execução principal
local initialData = getInitialDungeonData()
sendWebhook(initialData, true)

local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/JustLevel/goombahub/main/AriseCrossover.lua"))()
end)

if not success then
    warn("Erro ao executar loadstring: " .. tostring(result))
    return
end

wait(5)
if waitForDungeonLoad() then
    local fullData = getFullDungeonData(initialData.island)
    sendWebhook(fullData, false)
end
