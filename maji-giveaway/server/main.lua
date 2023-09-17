local discordWebhookUrl = Config.Webhook
local logFile = "license_identifiers.txt"
local playerCountFile = "player_count.txt"

local uniqueIdentifiers = {}

function sendDiscordWebhook(message)
    PerformHttpRequest(discordWebhookUrl, function(err, text, headers) end, 'POST', json.encode({content = message}), {['Content-Type'] = 'application/json'})
end

function readPlayerCount()
    local file = io.open(playerCountFile, "r")
    if file then
        local count = tonumber(file:read("*all"))
        file:close()
        return count or 0
    else
        return 0
    end
end

function writePlayerCount(count)
    local file = io.open(playerCountFile, "w")
    file:write(tostring(count))
    file:close()
end

local playerCount = readPlayerCount()

RegisterServerEvent("playerConnecting")
AddEventHandler("playerConnecting", function(playerName)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local licenseIdentifier
    local discordIdentifier

    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "license:") then
            licenseIdentifier = identifier
        elseif string.find(identifier, "discord:") then
            discordIdentifier = identifier
        end
    end

    if licenseIdentifier and not uniqueIdentifiers[licenseIdentifier] then
        uniqueIdentifiers[licenseIdentifier] = true
        playerCount = playerCount + 1
        writePlayerCount(playerCount)

        local file = io.open(logFile, "a")
        file:write(string.format("%d: %s - %s\n", playerCount, playerName, licenseIdentifier))
        file:close()

        if playerCount == Config.GiveawayNumber and discordIdentifier then
            local discordUserId = string.gsub(discordIdentifier, "discord:", "")
            sendDiscordWebhook(string.format("The "..Config.GiveawayNumber.."th member has joined! <@%s>", discordUserId))
        end
    end
end)