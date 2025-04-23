local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local webhookURL = "https://discord.com/api/webhooks/1347400165027217490/b0q6WACLsRPC_XjrNNNYXOKG-lRp9-vccdKxmlZE-wAMeraf5dZ5PQS0HWHd0THhp37V"

-- Function to wait for dungeon server load
local function waitForDungeonLoad()
    local timeout = 30 -- seconds
    local startTime = tick()
    while tick() - startTime < timeout do
        if game.Workspace:FindFirstChild("Dungeon") or Players.LocalPlayer.PlayerGui:FindFirstChild("DungeonUI") then
            return true
        end
        wait(0.5)
    end
    return false
end

-- Function to collect initial dungeon data (before teleport)
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

    -- Search for dungeon portal or data in client-accessible locations
    local possibleLocations = {
        game.Workspace:FindFirstChild("DungeonPortal"),
        game.Workspace:FindFirstChild("Dungeon"),
        ReplicatedStorage:FindFirstChild("DungeonData")
    }

    for _, location in ipairs(possibleLocations) do
        if location then
            local success, result = pcall(function()
                dungeonData.island = location:GetAttribute("Island") or location:GetAttribute("Location") or "Unknown"
                dungeonData.name = location:GetAttribute("Name") or location.Name or dungeonData.name
                dungeonData.type = location:GetAttribute("Type") or "Normal"
                dungeonData.rank = location:GetAttribute("Rank") or "C"
                dungeonData.status = location:GetAttribute("IsSpawned") and "Spawned" or "Not Spawned"
            end)
            if success then
                break
            else
                warn("Error accessing location data: " .. tostring(result))
            end
        end
    end

    -- Fallback: Search Workspace for portal-related objects
    if dungeonData.island == "Unknown" or dungeonData.name == "Unknown" then
        for _, obj in ipairs(game.Workspace:GetDescendants()) do
            if obj.Name:lower():match("portal") or obj.Name:lower():match("dungeon") then
                local success, result = pcall(function()
                    dungeonData.island = obj:GetAttribute("Island") or obj:GetAttribute("Location") or obj.Name:match("(%w+)%s*Portal") or dungeonData.island
                    dungeonData.name = obj:GetAttribute("Name") or obj.Name or dungeonData.name
                    dungeonData.type = obj:GetAttribute("Type") or "Normal"
                    dungeonData.rank = obj:GetAttribute("Rank") or "C"
                    dungeonData.status = "Spawned"
                end)
                if success then
                    break
                else
                    warn("Error accessing object data: " .. tostring(result))
                end
            end
        end
    end

    print("Initial Dungeon Data: Island=" .. dungeonData.island .. ", Name=" .. dungeonData.name)
    return dungeonData
end

-- Function to collect full dungeon data (after teleport)
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

    -- Check for dungeon in Workspace
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
            warn("Error accessing dungeon data: " .. tostring(result))
        end
    end

    -- Check PlayerGui for room display (e.g., "Room: 1/5")
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
                warn("Error parsing room display: " .. tostring(result))
            end
        end
    end

    print("Full Dungeon Data: Name=" .. dungeonData.name .. ", Rooms=" .. dungeonData.roomDisplay)
    return dungeonData
end

-- Function to create and send Discord embed
local function sendWebhook(data, isInitial)
    local embed = {
        ["title"] = "Galaxy-Notify-Arise: Dungeon Report",
        ["description"] = isInitial and 
            ("**Spawn Location: " .. data.island .. "**\nDungeon detected in AriseCrossover! 📡") or 
            ("**Spawn Location: " .. data.island .. "**\nDungeon activity in progress! 🌌"),
        ["color"] = 0x800080, -- Purple color
        ["fields"] = isInitial and {
            {["name"] = "Dungeon Name", ["value"] = data.name, ["inline"] = true},
            {["name"] = "Rank", ["value"] = data.rank, ["inline"] = true},
            {["name"] = "Type", ["value"] = data.type, ["inline"] = true},
            {["name"] = "Status", ["value"] = data.status, ["inline"] = true},
            {["name"] = "Server Job ID", ["value"] = data.serverJobId, ["inline"] = false}
        } or {
            {["name"] = "Dungeon Name", ["value"] = data.name, ["inline"] = true},
            {["name"] = "Rank", ["value"] = data.rank, ["inline"] = true},
            {["name"] = "Type", ["value"] = data.type, ["inline"] = true},
            {["name"] = "Status", ["value"] = data.status, ["inline"] = true},
            {["name"] = "Rooms", ["value"] = data.roomDisplay, ["inline"] = true},
            {["name"] = "Server Job ID", ["value"] = data.serverJobId, ["inline"] = false}
        },
        ["thumbnail"] = {
            ["url"] = "https://i.imgur.com/5y2Z9kB.png" -- Placeholder dungeon image
        },
        ["footer"] = {
            ["text"] = "Galaxy-Notify-Arise | Powered by xAI",
            ["icon_url"] = "https://i.imgur.com/8dk7zSg.png" -- Placeholder logo
        },
        ["timestamp"] = data.timestamp
    }

    local payload = {
        ["embeds"] = {embed},
        ["content"] = isInitial and "🌌 Dungeon Spawn Alert from Galaxy-Notify-Arise! 🌌" or "🌌 Dungeon Progress Update from Galaxy-Notify-Arise! 🌌"
    }

    local success, response = pcall(function()
        return HttpService:PostAsync(
            webhookURL,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if success then
        print("Webhook sent successfully!")
    else
        warn("Failed to send webhook: " .. tostring(response))
    end
end

-- Main execution
-- Step 1: Collect initial data (including island) and send webhook
local initialData = getInitialDungeonData()
sendWebhook(initialData, true)

-- Step 2: Execute loadstring to teleport to dungeon server
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/JustLevel/goombahub/main/AriseCrossover.lua"))()
end)

if not success then
    warn("Failed to execute loadstring: " .. tostring(result))
    return
end

-- Step 3: Wait for dungeon server load and collect full data
wait(5) -- Wait for teleport to complete
if waitForDungeonLoad() then
    local fullData = getFullDungeonData(initialData.island)
    sendWebhook(fullData, false)
end
