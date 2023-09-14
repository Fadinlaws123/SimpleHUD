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


if (Config.Main.useKMH == true) then
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
    SetTextDropShadow(0, 0, 0, 0, 255)
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

if (Config.Main.aopScript == true) then
    RegisterNetEvent('SimpleHUD:UpdateAOP')
    AddEventHandler('SimpleHUD:UpdateAOP', function(aop)
        aopText = aop
    end)
    TriggerEvent('chat:addSuggestion', '/aop', 'Change the current area of play.', {
        {name = 'Area', help = 'Place to put the AOP'}
    })
end

if (Config.Main.priorityScript == true) then
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
    if (Config.Main.aopScript == true) then
        TriggerServerEvent('SimpleHUD:grabAOP')
    end
    if (Config.Main.priorityScript == true) then
        TriggerServerEvent('SimpleHUD:grabPrio')
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if (Config.Main.aopScript == true) then
        TriggerServerEvent('SimpleHUD:grabAOP')
    end
    if (Config.Main.priorityScript == true) then
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

TriggerEvent("chat:addSuggestion", "/postal", "Mark a postal on the map", {{name = "postal", help = "The postal code"}})
TriggerEvent("chat:addSuggestion", "/p", "Mark a postal on the map", {{name = "postal", help = "The postal code"}})

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
                text("~s~Your Player ID: ~y~" .. GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))), 0.168, 0.804, 0.40, 4)
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
        end
    end
end)

if (Config.Main.realisticWeaponNames == true) then
    if(Config.Main.mark2Support == true) then
        Citizen.CreateThread(function()
            -- Pistols --
            AddTextEntry('WT_PIST2', 'Beretta 92')
            AddTextEntry('WT_REVOLVER2', 'Colt Anaconda')
            AddTextEntry('WT_SNSPISTOL2', 'AMT Backup')
            -- Assault Rifles --
            AddTextEntry('WT_RIFLE_ASL2', 'Type 56-2')
            AddTextEntry('WT_RIFLE_CBN2', 'Sig Mcx Virtus')
            AddTextEntry('WT_SPCARBINE2', 'G36K')
            AddTextEntry('WT_BULLRIFLE2', 'Kel-Tec RFB')
            -- Sub Machine Guns --
            AddTextEntry('WT_SMG2', 'SIG Sauer MPX')
            -- Machine Guns --
            AddTextEntry('WT_MG_CBT2', 'M60E4')
            -- Shotguns --
            AddTextEntry('WT_SG_PMP2', 'Winchester SX4')
            -- Snipers --
            AddTextEntry('WT_SNIP_HVY2', 'Serbu BFG-50A')
            AddTextEntry('WT_MKRIFLE2', 'M39 EMR/Mk')
        end)
    end
    if(Config.Main.customWeaponNames == true) then
        if(Config.Main.mark2Support == true) then
            Citizen.CreateThread(function()
                -- Pistols --
                AddTextEntry('WT_PIST2', Config.WeaponNames.pistolMRK2)
                AddTextEntry('WT_REVOLVER2', Config.WeaponNames.heavyRevolverMRK2)
                AddTextEntry('WT_SNSPISTOL2', Config.WeaponNames.snsPistolMRK2)
                -- Assault Rifles --
                AddTextEntry('WT_RIFLE_ASL2', Config.WeaponNames.assualtRifleMRK2)
                AddTextEntry('WT_RIFLE_CBN2', Config.WeaponNames.carbineRifleMRK2)
                AddTextEntry('WT_SPCARBINE2', Config.WeaponNames.specialCarbineMRK2)
                AddTextEntry('WT_BULLRIFLE2', Config.WeaponNames.bullpupRifleMRK2)
                -- Sub Machine Guns --
                AddTextEntry('WT_SMG2', Config.WeaponNames.smgMRK2)
                -- Machine Guns --
                AddTextEntry('WT_MG_CBT2', Config.WeaponNames.combatMGMRK2)
                -- Shotguns --
                AddTextEntry('WT_SG_PMP2', Config.WeaponNames.pumpShotgunMRK2)
                -- Snipers --
                AddTextEntry('WT_SNIP_HVY2', Config.WeaponNames.heavySniperMRK2)
                AddTextEntry('WT_MKRIFLE2', Config.WeaponNames.marksmanRifleMRK2)
            end)
        end
        Citizen.CreateThread(function()
            -- Pistols --
            AddTextEntry('WT_PIST', Config.WeaponNames.pistol)
            AddTextEntry('WT_PIST_CBT', Config.WeaponNames.combatPistol)
            AddTextEntry('WT_PIST_AP', Config.WeaponNames.apPistol)
            AddTextEntry('WT_PIST_50', Config.WeaponNames.pistol50)
            AddTextEntry('WT_STUN', Config.WeaponNames.stungun)
            AddTextEntry('WT_SNSPISTOL', Config.WeaponNames.snsPistol)
            AddTextEntry('WT_HVYPISTOL', Config.WeaponNames.heavyPistol)
            AddTextEntry('WT_VPISTOL', Config.WeaponNames.vintagePistol)
            AddTextEntry('WT_CERPST', Config.WeaponNames.ceramicPistol)
            AddTextEntry('WT_MKPISTOL', Config.WeaponNames.marksmanPistol)
            AddTextEntry('WT_REVOLVER', Config.WeaponNames.heavyRevolver)
            AddTextEntry('WT_REV_DA', Config.WeaponNames.doubleActionRevolver)
            AddTextEntry('WT_REV_NV', Config.WeaponNames.navyRevolver)
            AddTextEntry('WT_GDGTPST', Config.WeaponNames.pericoPistol)
            -- Sub Machine Guns --
            AddTextEntry('WT_SMG_MCR', Config.WeaponNames.microSMG)
            AddTextEntry('WT_SMG', Config.WeaponNames.smg)
            AddTextEntry('WT_SMG_ASL', Config.WeaponNames.assaultSMG)
            AddTextEntry('WT_MCHPIST', Config.WeaponNames.machinePistol)
            AddTextEntry('WT_MINISMG', Config.WeaponNames.miniSMG)
            AddTextEntry('WT_COMBATPDW', Config.WeaponNames.combatPDW)
            AddTextEntry('WT_GUSNBRG', Config.WeaponNames.gusenburgSweeper)
            -- Assault Rifles --
            AddTextEntry('WT_RIFLE_ASL', Config.WeaponNames.assaultRifle)
            AddTextEntry('WT_RIFLE_CBN', Config.WeaponNames.carbineRifle)
            AddTextEntry('WT_RIFLE_ADV', Config.WeaponNames.advancedRifle)
            AddTextEntry('WT_SPCARBINE', Config.WeaponNames.specialCarbine)
            AddTextEntry('WT_BULLRIFLE', Config.WeaponNames.bullpupRifle)
            AddTextEntry('WT_CMPRIFLE', Config.WeaponNames.compactRifle)
            AddTextEntry('WT_MLTRYRFL', Config.WeaponNames.militaryRifle)
            -- Machine Guns --
            AddTextEntry('WT_MG', Config.WeaponNames.mg)
            AddTextEntry('WT_MG_CBT', Config.WeaponNames.combatMG)
            -- Shotguns --
            AddTextEntry('WT_SG_PMP', Config.WeaponNames.pumpShotgun)
            AddTextEntry('WT_SG_SOF', Config.WeaponNames.sawedOffShotgun)
            AddTextEntry('WT_SG_ASL', Config.WeaponNames.assaultShotgun)
            AddTextEntry('WT_SG_BLP', Config.WeaponNames.bullpupShotgun)
            AddTextEntry('WT_HVYSHGN', Config.WeaponNames.heavyShotgun)
            AddTextEntry('WT_CMBSHGN', Config.WeaponNames.combatShotgun)
            -- Snipers --
            AddTextEntry('WT_SNIP_RIF', Config.WeaponNames.sniperRifle)
            AddTextEntry('WT_SNIP_HVY', Config.WeaponNames.heavySniper)
            AddTextEntry('WT_MKRIFLE', Config.WeaponNames.marksmanRifle)
            -- Rocket Launchers --
            AddTextEntry('WT_GL', Config.WeaponNames.grenadeLauncher)
            -- Misc --
            AddTextEntry('WT_MINIGUN', Config.WeaponNames.minigun)
            AddTextEntry('WT_GNADE_STK', Config.WeaponNames.stickyBomb)
        end)
    else
        Citizen.CreateThread(function()
            -- Pistols --
            AddTextEntry('WT_PIST', 'M9 Beretta')
            AddTextEntry('WT_PIST_CBT', 'Glock 17')
            AddTextEntry('WT_PIST_AP', 'Glock 18')
            AddTextEntry('WT_PIST_50', 'Desert Eagle')
            AddTextEntry('WT_STUN', 'X-26')
            AddTextEntry('WT_SNSPISTOL', 'Heckler & Koch P7M10')
            AddTextEntry('WT_HVYPISTOL', 'Enterprise 1911')
            AddTextEntry('WT_VPISTOL', 'FN Model 1922')
            AddTextEntry('WT_CERPST', 'Heckler & Koch P7')
            AddTextEntry('WT_MKPISTOL', 'Thompson/Center Contender G2')
            AddTextEntry('WT_REVOLVER', 'Taurus Raging Bull')
            AddTextEntry('WT_REV_DA', 'Colt M1892')
            AddTextEntry('WT_REV_NV', 'Colt 1851')
            AddTextEntry('WT_GDGTPST', 'P08 Luger')
            -- Sub Machine Guns --
            AddTextEntry('WT_SMG_MCR', 'UZI')
            AddTextEntry('WT_SMG', 'MP5')
            AddTextEntry('WT_SMG_ASL', 'FN P90')
            AddTextEntry('WT_MCHPIST', 'TEC-9')
            AddTextEntry('WT_MINISMG', 'Škorpion Vz. 82')
            AddTextEntry('WT_COMBATPDW', 'SIG MPX')
            AddTextEntry('WT_GUSNBRG', '45 ACP M1928A1 Thompson')
            -- Assault Rifles --
            AddTextEntry('WT_RIFLE_ASL', 'AK-47')
            AddTextEntry('WT_RIFLE_CBN', 'M4A1')
            AddTextEntry('WT_RIFLE_ADV', 'CTAR-21')
            AddTextEntry('WT_SPCARBINE', 'G36C')
            AddTextEntry('WT_BULLRIFLE', 'QBZ-95')
            AddTextEntry('WT_CMPRIFLE', 'AK Carbine')
            AddTextEntry('WT_MLTRYRFL', 'Steyr AUG A3')
            -- Machine Guns --
            AddTextEntry('WT_MG', 'PKM')
            AddTextEntry('WT_MG_CBT', 'M249')
            -- ShotGuns --
            AddTextEntry('WT_SG_PMP', 'Model 870')
            AddTextEntry('WT_SG_SOF', 'Mossberg 500')
            AddTextEntry('WT_SG_ASL', 'UTAS UTS-15')
            AddTextEntry('WT_SG_BLP', 'KSG')
            AddTextEntry('WT_HVYSHGN', 'Saiga 12')
            AddTextEntry('WT_CMBSHGN', 'Spas-12')
            -- Snipers --
            AddTextEntry('WT_SNIP_RIF', 'AWF')
            AddTextEntry('WT_SNIP_HVY', 'Barrett M82')
            AddTextEntry('WT_MKRIFLE', 'M39 EMR/Mk')
            -- Rocket Launchers --
            AddTextEntry('WT_GL', 'Milkor MGL')
            -- Misc --
            AddTextEntry('WT_MINIGUN', 'M134 Minigun')
            AddTextEntry('WT_GNADE_STK', 'C4')
        end)
    end
end

if(Config.Main.hideRadarOnFoot == true) then
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
