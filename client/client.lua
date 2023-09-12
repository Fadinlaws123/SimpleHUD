local priorityText = ""
local aopText = ""
local zoneName = ""
local streetName = ""
local crossingRoad = ""
local nearestPostal = {}
local compass = ""
local time = ""
local hidden = false
local postals = {}


if(Config.Main.useKMH == true) then
    speedCalc = 3.6
    speedText = "kmh"
else
    speedCalc = 2.236936
    speedText = "mph"
end

function getAOP()
    return aopText
end

function text(text, x, y, scale, font)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextOutline()
    SetTextJustification(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function getHeading(heading)
    if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
        return "N" -- North
    elseif (heading >= 45 and heading < 135) then
        return "W" -- West
    elseif (heading >= 135 and heading < 225) then
        return "S" -- South
    elseif (heading >= 225 and heading < 315) then
        return "E" -- East
    else
        return " "
    end
end

function getTime()
    hour = GetClockHours()
    minute = GetClockMinutes()
    if hour <= 9 then
        hour = "0" .. hour
    end
    if minute <= 9 then
        minute = "0" .. minute
    end
    return hour .. ":" .. minute
end

if(Config.Main.aopScript == true) then
    RegisterNetEvent('SimpleHUD:UpdateAOP')
    AddEventHandler('SimpleHUD:UpdateAOP', function(aop)
        aopText = aop
    end)
    TriggerEvent('chat:addSuggestion', '/aop', 'Change the current area of play.', {
        {name = 'Area', help = 'Place to put the AOP'}
    })
end

if(Config.Main.priorityScript == true) then
    TriggerEvent('chat:addSuggestion', '/pstart', 'Start a priority in the server!')
    TriggerEvent('chat:addSuggestion', '/pend', 'End the priority you are apart of!')
    TriggerEvent('chat:addSuggetion', '/pcooldown', 'Enable a cooldown for the priorities!', {
        {name = 'Time', help = 'How long in minutes to have a cooldown!'}
    })
    TriggerEvent('chat:addSuggestion', '/pjoin', 'Join an active priority!')
    TriggerEvent('chat:addSuggestion', '/pleave', 'Leave the current priority!')

    RegisterNetEvent('SimpleHUD:UpdatePrio')
    AddEventHandler('SimpleHUD:UpdatePrio', function(priority)
        priorityText = priority
    end)
end

AddEventHandler('playerSpawned', function()
    if(Config.Main.aopScript == true) then
        TriggerServerEvent('SimpleHUD:grabAOP')
    end
    if(Config.Main.priorityScript == true) then
        TriggerServerEvent('SimpleHUD:grabPrio')
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return 
    end
    if(Config.Main.aopScript == true) then 
        TriggerServerEvent('SimpleHUD:grabAOP')
    end
    if(Config.Main.priorityScript == true) then
        TriggerServerEvent('SimpleHUD:grabPrio')
    end
end)

function markPostal(code)
    for i = 1, #postals do
        local postal = postals[i]
        if postal.code == code then
            SetNewWaypoint(postal.coords.x, postal.coords.y)
            return
        end
    end
end

RegisterCommand("postal", function(source, args, rawCommand)
    if #args <= 0 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"~w~[~r~SimpleHUD~w~] ", "~r~Waypoint Removed!"}
        })
        DeleteWaypoint()
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"~w~[~r~SimpleHUD~w~] ", "~g~Waypoint set for ~y~" .. args[1]}
        })
        markPostal(args[1])
    end
end, false)

RegisterCommand("p", function(source, args, rawCommand)
    if #args <= 0 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"~w~[~r~SimpleHUD~w~] ", "~r~Waypoint Removed!"}
        })
        DeleteWaypoint()
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"~w~[~r~SimpleHUD~w~] ", "~g~Waypoint set for ~y~" .. args[1]}
        })
        markPostal(args[1])
    end
end, false)

TriggerEvent("chat:addSuggestion", "/postal", "Mark a postal on the map", {{name="postal", help="The postal code"}})
TriggerEvent("chat:addSuggestion", "/p", "Mark a postal on the map", {{name="postal", help="The postal code"}})

function getPostal()
    return nearestPostal.code, nearestPostal
end

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

CreateThread(function()
    local totalPostals = #postals
    while true do
        ped = PlayerPedId()
        pedCoords = GetEntityCoords(ped)
        local nearestDist = nil
        local nearestIndex = nil
        local coords = vec(pedCoords.x, pedCoords.y)

        for i = 1, totalPostals do
            local dist = #(coords - postals[i].coords)
            if not nearestDist or dist < nearestDist then
                nearestDist = dist
                nearestIndex = i
            end
        end

        nearestPostal = postals[nearestIndex]

        streetName, crossingRoad = GetStreetNameAtCoord(pedCoords.x, pedCoords.y, pedCoords.z)
        streetName = GetStreetNameFromHashKey(streetName)
        crossingRoad = GetStreetNameFromHashKey(crossingRoad)
        zoneName = GetLabelText(GetNameOfZone(pedCoords.x, pedCoords.y, pedCoords.z))
        if Config.streetNames[streetName] then
            streetName = Config.streetNames[streetName]
        end
        if Config.streetNames[crossingRoad] then
            crossingRoad = Config.streetNames[crossingRoad]
        end
        if Config.zoneNames[GetLabelText(zoneName)] then
            zoneName = Config.zoneNames[GetLabelText(zoneName)]
        end
        if getHeading(GetEntityHeading(ped)) then
            compass = getHeading(GetEntityHeading(ped))
        end
        if crossingRoad ~= "" then
            streetName = streetName .. " ~c~/ " .. crossingRoad
        else
            streetName = streetName
        end

        Wait(1000)
    end
end)

CreateThread(function()
    Wait(500)
    while true do
        Wait(300)
        time = getTime()
        hidden = IsHudHidden()
        vehicle = GetVehiclePedIsIn(ped)
        vehClass = GetVehicleClass(vehicle)
        driver = GetPedInVehicleSeat(vehicle, -1)
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if not hidden then
            if Config.Main.aopScript then
                text("~s~AOP: ~y~" .. aopText, 0.168, 0.868, 0.40, 4)
            end
            if Config.Main.discordScript then
                text("~s~Discord: ~b~" .. Config.Main.DiscordURL, 0.168, 0.847, 0.40, 4)
            end
            if Config.Main.onlinePlayers then
                text("~s~Online Players: ~y~" .. GetNumberOfPlayers() .. "/" .. Config.Main.maxPlayers, 0.168, 0.825, 0.40, 4)
            end
            if Config.Main.playerID then
                text("~s~Your Player ID: ~y~" .. GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))), 0.168, 0.806, 0.40, 4)
            end
            if Config.Main.priorityScript then
                text(priorityText, 0.168, 0.890, 0.40, 4)
            end
            if (Config.Main.postalScript and nearestPostal and nearestPostal.code) then
                text("~s~Nearby Postal: ~c~(~y~" .. nearestPostal.code .. "~c~)", 0.168, 0.912, 0.40, 4)
            end
            text("~c~" .. time .. " ~s~" .. zoneName, 0.168, 0.96, 0.40, 4)
            text("~c~| ~s~" .. compass .. " ~c~| ~s~" .. streetName, 0.168, 0.932, 0.55, 4)
        end
        if vehicle ~= 0 and vehClass ~= 13 and driver then
            DrawRect(0.139, 0.947, 0.035, 0.03, 0, 0, 0, 100)
            text(tostring(math.ceil(GetEntitySpeed(vehicle) * speedCalc)), 0.124, 0.931, 0.5, 4)
            text(speedText, 0.14, 0.94, 0.3, 4)
            if (Config.Main.fuelHUD) then
                local fuelLevel = (0.141 * GetVehicleFuelLevel(vehicle)) / 100
                DrawRect(0.0855, 0.8, 0.141, 0.010 + 0.006, 40, 40, 40, 150) 
                if (Config.ElectricVehicles[GetEntityModel(vehicle)]) then
                    DrawRect(0.0855, 0.8, 0.141, 0.010, 20, 140, 255, 100)  
                    DrawRect(0.0855 - (0.141 - fuelLevel) / 2, 0.8, fuelLevel, 0.010, 20, 140, 255, 255)  
                else
                    DrawRect(0.0855, 0.8, 0.141, 0.010, 206, 145, 40, 100)  
                    DrawRect(0.0855 - (0.141 - fuelLevel) / 2, 0.8, fuelLevel, 0.010, 206, 145, 0, 255) 
                end
            end
        end
    end
end)


