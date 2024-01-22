if Config.Scripts.AOPSystem then
    local aop = Config.AOPConfig.DefaultAOP
    RegisterCommand("aop", function(source, args, rawCommand)
        local player = source
        if Config.AOPConfig.usePermissions then 
            if IsPlayerAceAllowed(source, Config.AOPConfig.acePerm) then
                aop = table.concat(args, " ")
                TriggerClientEvent("SimpleHUD:AOP:ChangeAOP", -1, aop)
                TriggerClientEvent("chat:addMessage", -1, {
                    color = {0, 130, 255},
                    multiline = true,
                    args = {"~w~[~b~SimpleHUD~w~] ", "~y~AOP Updated by ~b~" .. GetPlayerName(source) .. "~y~! New area is: ^*~r~" .. aop .. "!"}
                })
            else
                TriggerClientEvent('chat:addMessage', player, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"~w~[~b~SimpleHUD~w~] ", '~r~ERROR: ~y~You do not have the permissions required to change the AOP!'}
                })
            end
        else
            aop = table.concat(args, " ")
            TriggerClientEvent("SimpleHUD:AOP:ChangeAOP", -1, aop)
            TriggerClientEvent("chat:addMessage", -1, {
                color = {0, 130, 255},
                multiline = true,
                args = {"~b~SimpleHUD", "~y~AOP Updated by ~b~" .. GetPlayerName(source) .. "~y~! New area is: ^*~r~" .. aop .. "!"}
            })
        end
    end)
    
    RegisterNetEvent("SimpleHUD:AOP:getAop")
    AddEventHandler("SimpleHUD:AOP:getAop", function()
        local player = source
        TriggerClientEvent("SimpleHUD:AOP:ChangeAOP", player, aop)
    end)
end

if Config.Scripts.postalSystem then
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
end