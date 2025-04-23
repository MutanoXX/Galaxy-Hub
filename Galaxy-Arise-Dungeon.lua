local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local webhookURL = "https://discord.com/api/webhooks/1347400165027217490/b0q6WACLsRPC_XjrNNNYXOKG-lRp9-vccdKxmlZE-wAMeraf5dZ5PQS0HWHd0THhp37V"

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
    return false
end

-- Função para encontrar o portal da dungeon
local function findDungeonPortal()
    local dungeonsFolder = game.Workspace:FindFirstChild("Dungeons") or game.Workspace
    for _, obj in ipairs(dungeonsFolder:GetDescendants()) do
        if obj.Name:lower():match("portal") and obj:GetAttribute("Island") then
            return obj
        end
    end
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
            dungeonData.type = portal:GetAttribute("Type") or "Normal"
            dungeonData.rank = portal:GetAttribute("Rank") or "C"
            dungeonData.status = "Spawned"
        end)
        if not success then
            warn("Erro ao acessar dados do portal: " .. tostring(result))
        end
    end

    print("Dados Iniciais: Island=" .. dungeonData.island .. ", Name=" .. dungeonData.name)
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

    local dungeonObj = game.Workspace:FindFirstChild("Dungeon")
    if dungeonObj then
        local success, result = pcall(function()
            dungeonData.name = dungeonObj:GetAttribute("Name") or dungeonObj.Name or dungeonData.name
            dungeonData.type = dungeonObj:GetAttribute("Type") or "Normal"
            dungeonData.rank = dungeonObj:GetAttribute("Rank") or "C"
            dungeonData.totalRooms = dungeonObj:GetAttribute("TotalRooms") or 0
            dungeonData.currentRoom = dungeonObj:GetAttribute("CurrentRoom") or 0
            dungeonData.roomDisplay = "Room: " .. dungeonData.currentRoom .. "/" .. dungeonData.totalRooms
        end)
        if not success then
            warn("Erro ao acessar dados da dungeon: " .. tostring(result))
        end
    end

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
                break
            else
                warn("Erro ao parsear exibição de sala: " .. tostring(result))
            end
        end
    end

    print("Dados Completos: Name=" .. dungeonData.name .. ", Rooms=" .. dungeonData.roomDisplay)
    return dungeonData
end

-- Função para criar e enviar o embed do Discord
local function sendWebhook(data, isInitial)
    local embed = {
        title = "Galaxy-Notify-Arise: Dungeon Report",
        description = isInitial and 
            ("**Spawn Location: " .. data.island .. "**\nDungeon detected in AriseCrossover! 📡") or 
            ("**Spawn Location: " .. data.island .. "**\nDungeon activity in progress! 🌌"),
        color = 0x800080,
        fields = isInitial and {
            {name = "Dungeon Name", value = data.name, inline = true},
            {name = "Rank", value = data.rank, inline = true},
            {name = "Type", value = data.type, inline = true},
            {name = "Status", value = data.status, inline = true},
            {name = "Server Job ID", value = data.serverJobId, inline = false}
        } or {
            {name = "Dungeon Name", value = data.name, inline = true},
            {name = "Rank", value = data.rank, inline = true},
            {name = "Type", value = data.type, inline = true},
            {name = "Status", value = data.status, inline = true},
            {name = "Rooms", value = data.roomDisplay, inline = true},
            {name = "Server Job ID", value = data.serverJobId, inline = false}
        },
        footer = {
            text = "Galaxy-Notify-Arise | Powered by xAI"
        },
        timestamp = data.timestamp
    }

    local payload = {
        embeds = {embed},
        content = isInitial and "🌌 Dungeon Spawn Alert from Galaxy-Notify-Arise! 🌌" or "🌌 Dungeon Progress Update from Galaxy-Notify-Arise! 🌌"
    }

    local success, response = pcall(function()
        return HttpService:PostAsync(
            webhookURL,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if success then
        print("Webhook enviado com sucesso!")
    else
        warn("Erro ao enviar webhook: " .. tostring(response))
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
