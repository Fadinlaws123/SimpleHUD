
local aopText = ""
local zoneName = ""
local streetName = ""
local crossingRoad = ""
local nearestPostal = {}
local compass = ""
local time = ""
local postals = {}


function getAOP()
    return aopText
end

function Notify(Text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(Text)
    DrawNotification(true, true)
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
        return "N"
    elseif (heading >= 45 and heading < 135) then
        return "W"
    elseif (heading >= 135 and heading < 225) then
        return "S"
    elseif (heading >= 225 and heading < 315) then
        return "E"
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

if Config.Scripts.HideRadarOnFoot then
    Citizen.CreateThread(function()
        Citizen.Wait(100)
        
        while true do
            if not IsPedInAnyVehicle(PlayerPedId()) and IsRadarEnabled() then
                DisplayRadar(false)
            elseif IsPedInAnyVehicle(PlayerPedId()) and not IsRadarEnabled() then
                DisplayRadar(true)
            end
            
            Citizen.Wait(500)
        end
    end)
end

if Config.Scripts.AOPSystem then    
    RegisterNetEvent("SimpleHUD:AOP:ChangeAOP")
    AddEventHandler("SimpleHUD:AOP:ChangeAOP", function(aop)
        aopText = aop
    end)
    TriggerEvent("chat:addSuggestion", "/aop", "Change the current area of play?", {{name="Area", help=""}})

    AddEventHandler("playerSpawned", function()
        if Config.Scripts.AOPSystem then
            TriggerServerEvent("SimpleHUD:AOP:getAop")
        end
    end)

    RegisterNetEvent("SimpleHUD:AOP:SuccessMessage")
    AddEventHandler("SimpleHUD:AOP:SuccessMessage", function()
        Notify(Config.Messages.AOPSuccess)
    end)

    RegisterNetEvent("SimpleHUD:AOP:ErrorMessage")
    AddEventHandler("SimpleHUD:AOP:ErrorMessage", function()
        Notify(Config.Messages.AOPError)
    end)
end

if Config.SpeedHUD.speedMeasurement == 'kmph' then
    speedCalc = 3.6
    speedText = "kmph"
elseif Config.SpeedHUD.speedMeasurement == 'mph' then
    speedCalc = 2.236936
    speedText = "mph"
end

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    Wait(3000)
    if Config.Scripts.AOPSystem then
        TriggerServerEvent("SimpleHUD:AOP:getAop")
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
        Notify(Config.Messages.PostalDelete)
        DeleteWaypoint()
    else
        Notify(Config.Messages.PostalSet)
        markPostal(args[1])
    end
end)

TriggerEvent("chat:addSuggestion", "/postal", "Mark a postal on the map", {
    { name = "postal", help = "The postal code"}
})

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
        if Config.StreetLabel.streetNames[streetName] then
            streetName = Config.StreetLabel.streetNames[streetName]
        end
        if Config.StreetLabel.streetNames[crossingRoad] then
            crossingRoad = Config.StreetLabel.streetNames[crossingRoad]
        end
        if Config.StreetLabel.zoneNames[GetLabelText(zoneName)] then
            zoneName = Config.StreetLabel.zoneNames[GetLabelText(zoneName)]
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
        Wait(0.1)
        if Config.Scripts.AOPSystem then
            text("~s~AOP: ~y~" .. aopText, 0.168, 0.820, 0.45, 4)
        end
        if Config.Scripts.DiscordHUDSystem then
            text("~s~Our Discord: ~b~" .. Config.DiscordSystem.DiscordLink, 0.168, 0.793, 0.45, 4)
        end
        if Config.Scripts.postalSystem and nearestPostal and nearestPostal.code then
            text("~s~Nearest Postal: ~c~(~y~" .. nearestPostal.code .. "~c~)", 0.168, 0.845, 0.45, 4)
        end
        text("~c~" .. time .. " ~s~" .. zoneName, 0.168, 0.947, 0.40, 4)
        text("~c~| ~s~" .. compass .. " ~c~| ~s~" .. streetName, 0.168, 0.921, 0.55, 4)
        if Config.SpeedHUD.speedMeasurement == 'mph' then
            Speed = GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false)) * 2.236936
        elseif Config.SpeedHUD.speedMeasurement == 'kmph' then
            Speed = GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false)) * 3.6
        end
        
        if vehicle ~= 0 and driver then
            local barHeight = 0.190
            local barWidth = 0.005
            local barPos = { x = 0.165, y = 0.872 }
            local currentFuel = GetVehicleFuelLevel(vehicle)
            local fuelHeight = (barHeight * currentFuel) / 100
            DrawRect(barPos.x, barPos.y, barWidth, barHeight, 40, 40, 40, 150)  -- Full fuel bar (black)
            DrawRect(barPos.x, barPos.y + (barHeight - fuelHeight) / 2, barWidth, fuelHeight, 206, 145, 0, 255)  -- Curent fuel bar (yellow)
            DrawRect(0.139, 0.947, 0.035, 0.03, 0, 0, 0, 100)
            text(tostring(math.ceil(GetEntitySpeed(vehicle) * speedCalc)), 0.124, 0.931, 0.5, 4)
            text(speedText, 0.14, 0.94, 0.3, 4)
        end
    end
end)