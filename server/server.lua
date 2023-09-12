function getUserDiscordInfo(discordUserId)
    local data
    PerformHttpRequest("https://discordapp.com/api/guilds/" .. Config.Main.guildID .. "/members/" .. discordUserId, function(errorCode, resultData, resultHeaders)
		if errorCode ~= 200 then
            return
        end
        local result = json.decode(resultData)
        local roles = {}
        for _, roleId in pairs(result.roles) do
            roles[roleId] = roleId
        end
        data = {
            nickname = result.nick,
            discordTag = tostring(result.user.username) .. "#" .. tostring(result.user.discriminator),
            roles = roles
        }
    end, "GET", "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. Config.Main.botToken})
    while not data do
        Citizen.Wait(0)
    end
    return data
end

function GetPlayerIdentifierFromType(type, source)
    local identifierCount = GetNumPlayerIdentifiers(source)
    for count = 0, identifierCount do
        local identifier = GetPlayerIdentifier(source, count)
        if identifier and string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

if(Config.Main.priorityScript == true) then
    local priority = "~w~Priority: ~g~Available!"
    local priorityPlayers = {}
    local isPriorityCooldown = false
    local isPriorityActive = false


    function tableConcat(table, concat)
        local string = ""
        local first = true
        for _, v in pairs(table) do
            if first then
                string = tostring(v)
                first = false
            else
                string = string .. concat .. tostring(v)
            end
        end
        return string
    end

    function tableCount(table)
        local count = 0
        for _ in pairs(table) do
            count = count + 1
        end
        return count
    end

    function priorityCooldown(time)
        isPriorityActive = false
        isPriorityCooldown = true
        for cooldown = time, 1, -1 do
            if cooldown > 1 then
                priority = "~w~Priority Cooldown: ~y~" .. cooldown .. "~w~ minutes"
            else
                priority = "~w~Priority Cooldown: ~y~" .. cooldown .. "~w~ minute"
            end
            TriggerClientEvent("SimpleHUD:UpdatePrio", -1, priority)
            Citizen.Wait(60000)
        end
        priority = "~w~Priority: ~g~Available!"
        TriggerClientEvent("SimpleHUD:UpdatePrio", -1, priority)
        isPriorityCooldown = false
    end

    RegisterNetEvent("SimpleHUD:grabPrio")
    AddEventHandler("SimpleHUD:grabPrio", function()
        local player = source
        TriggerClientEvent("SimpleHUD:UpdatePrio", player, priority)
    end)

    RegisterCommand("pstart", function(source, args, rawCommand)
        local player = source
        if isPriorityCooldown then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"~w~[~r~SimpleHUD~w~] ", "~r~ERROR: ^3Cannot start priority due to cooldown."}
            })
            return
        end
        if isPriorityActive then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"~w~[~r~SimpleHUD~w~] ", "~r~ERROR: ^3There's already an active priority."}
            })
            return
        end
        TriggerClientEvent("chat:addMessage", -1, {
            color = {255, 0, 0},
            multiline = true,
            args = {"~w~[~r~SimpleHUD~w~] ", "~y~A priority has been initiated by ~r~" .. GetPlayerName(source) .. "! ~y~All civilians not involved, stay clear of the current situation!"}
        })
        isPriorityActive = true
        priorityPlayers[player] = GetPlayerName(player) .. " #" .. player
        priority = "~w~Priority: ~r~Active! ~w~(" .. tableConcat(priorityPlayers, ", ") .. ")"
        TriggerClientEvent("SimpleHUD:UpdatePrio", -1, priority)
    end, false)

    RegisterCommand("pend", function(source, args, rawCommand)
        local player = source
        if not isPriorityActive then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"~w~[~r~SimpleHUD~w~] ", "~r~ERROR: ^3There's no active priority to stop."}
            })
            return
        end
        TriggerClientEvent("chat:addMessage", -1, {
            color = {255, 0, 0},
            multiline = true,
            args = {"~w~[~r~SimpleHUD~w~] ", "~y~The current priority has ended! Priority Cooldown has been started by: ~r~SimpleHUD ~y~for: ~r~" .. Config.Main.priorityCooldown .. " minutes!"}
        })
        priorityPlayers = {}
        priorityCooldown(Config.Main.priorityCooldown)
    end, false)


    RegisterCommand("pcooldown", function(source, args, rawCommand)
        local player = source

        if #Config.Main.botToken > 1 and #Config.Main.guildID > 1 then
            local discordUserId = string.gsub(GetPlayerIdentifierFromType("discord", player), "discord:", "")
            local roles = getUserDiscordInfo(discordUserId).roles
            local hasPerms = false
        
            for _, roleId in pairs(Config.Main.prioPermissions) do
                if roles[roleId] or roleId == "0" or roleId == 0 then
                    hasPerms = true
                    TriggerClientEvent("chat:addMessage", -1, {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"~w~[~r~SimpleHUD~w~] ", "~y~Priority Cooldown started by ~r~" .. GetPlayerName(source) .. ' ~y~for: ~r~' .. args[1] .. ' ~y~minutes!'}
                    })
                    break
                end
            end

            if not hasPerms then
                TriggerClientEvent("chat:addMessage", player, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"~w~[~r~SimpleHUD~w~] ", "~r~ERROR: You don't have permission to use this command."}
                })
                return
            end
        end

        local time = tonumber(args[1])
        if time and time > 0 then
            priorityCooldown(time)
        end
    end, false)

    RegisterCommand("pjoin", function(source, args, rawCommand)
        local player = source
        if not isPriorityActive then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"~w~[~r~SimpleHUD~w~] ", "~r~ERROR: ^3There's no active priority to join."}
            })
            return
        end
        if priorityPlayers[player] then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"~w~[~r~SimpleHUD~w~] ", "~r~ERROR: ^3You're already in this priority."}
            })
            return
        end
        TriggerClientEvent("chat:addMessage", -1, {
            color = {255, 0, 0},
            multiline = true,
            args = {"~w~[~r~SimpleHUD~w~] ", "~r~" .. GetPlayerName(source) .. "~y~ Has joined the current priority!"}
        })
        priorityPlayers[player] = GetPlayerName(player) .. " #" .. player
        priority = "~w~Priority: ~r~Active ~w~(" .. tableConcat(priorityPlayers, ", ") .. ")"
        TriggerClientEvent("SimpleHUD:UpdatePrio", -1, priority)
    end, false)

    RegisterCommand("pleave", function(source, args, rawCommand)
        local player = source
        if not isPriorityActive then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"~w~[~r~SimpleHUD~w~] ", "~r~ERROR: ^3There's no active priority to leave."}
            })
            return
        end
        if tableCount(priorityPlayers) == 1 and priorityPlayers[player] == (GetPlayerName(player) .. " #" .. player) then
            priorityPlayers = {}
            TriggerClientEvent("chat:addMessage", -1, {
                color = {255, 0, 0},
                multiline = true,
                args = {"~w~[~r~SimpleHUD~w~] ", "~y~The current priority has ended! Priority Cooldown has been started by: ~r~SimpleHUD ~y~for: ~r~" .. Config.Main.priorityCooldown .. " minutes!"}
            })
            priorityCooldown(Config.Main.priorityCooldown)
        else
            priorityPlayers[player] = nil
            priority = "~w~Priority: ~r~Active ~w~(" .. tableConcat(priorityPlayers, ", ") .. ")"
        end
        TriggerClientEvent("chat:addMessage", -1, {
            color = {255, 0, 0},
            multiline = true,
            args = {"~w~[~r~SimpleHUD~w~] ", "~r~" .. GetPlayerName(source) .. "~y~ Has left the current priority!"}
        })
        TriggerClientEvent("SimpleHUD:UpdatePrio", -1, priority)
    end, false)
end

if (Config.Main.aopScript == true) then
    local aop = Config.Main.defaultAOP
    RegisterCommand("aop", function(source, args, rawCommand)
        local player = source

        if #Config.Main.botToken > 1 and #Config.Main.guildID > 1 then
            local discordUserId = string.gsub(GetPlayerIdentifierFromType("discord", player), "discord:", "")
            local roles = getUserDiscordInfo(discordUserId).roles
            local hasPerms = false
        
            for _, roleId in pairs(Config.Main.aopPermissions) do
                if roles[roleId] or roleId == "0" or roleId == 0 then
                    hasPerms = true
                    break
                end
            end

            if not hasPerms then
                TriggerClientEvent("chat:addMessage", player, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"~w~[~r~SimpleHUD~w~] ", "~r~ERROR: ^3You don't have permission to use this command."}
                })
                return
            end
        end

        aop = table.concat(args, " ")
        TriggerClientEvent("SimpleHUD:UpdateAOP", -1, aop)
        TriggerClientEvent("chat:addMessage", -1, {
            color = {0, 130, 255},
            multiline = true,
            args = {"^1AOP", "^3New Area of Player: ^*" .. aop .. "."}
        })
    end, false)
    
    RegisterNetEvent("SimpleHUD:grabAOP")
    AddEventHandler("SimpleHUD:grabAOP", function()
        local player = source
        TriggerClientEvent("SimpleHUD:UpdateAOP", player, aop)
    end)
end

local postals = {}
CreateThread(function()
    postals = json.decode(LoadResourceFile(GetCurrentResourceName(), "postals.json"))
    for i = 1, #postals do
        local postal = postals[i]
        postals[i] = {
            coords = vec(postal.x, postal.y),
            code = postal.code
        }
    end
end)

function getPostal(source)
    local ped = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(ped)
    local coords = vec(pedCoords.x, pedCoords.y)
    local nearestPostal = nil
    local nearestDist = nil
    local nearestIndex = nil

    for i = 1, #postals do
        local dist = #(coords - postals[i].coords)
        if not nearestDist or dist < nearestDist then
            nearestIndex = i
            nearestDist = dist
        end
    end
    nearestPostal = postals[nearestIndex]

    return nearestPostal.code, nearestPostal
end