--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()

local function CountCops()
    local count = QBCore.Functions.GetDutyCount("police")
    return count
end

QBCore.Commands.Add("startHunt", "", {}, false, function(source, args)
    if args[1] and tonumber(args[1]) > 0 then
        local id = tonumber(args[1])
        local amount = tonumber(args[2]) 
        if amount > Config.MaxVehicleSpawn then amount = Config.MaxVehicleSpawn end
        TriggerEvent("mh-hunters:server:start", id, amount)
    end
end, 'admin')

QBCore.Commands.Add("stopHunt", "", {}, false, function(source, args)
    if args[1] and tonumber(args[1]) > 0 then
        local id = tonumber(args[1])
        TriggerClientEvent("mh-hunters:client:stopHunt", id)
    end
end, 'admin')

RegisterServerEvent('mh-hunters:server:start')
AddEventHandler('mh-hunters:server:start', function(amount)
    local src = source
    if Config.EnableIfNoCopsOnline then
        TriggerClientEvent("mh-hunters:client:startHunt", src, amount, CountCops())
    else
        TriggerClientEvent("mh-hunters:client:startHunt", src, amount, 0)
    end
end)

RegisterServerEvent('mh-hunters:server:stop')
AddEventHandler('mh-hunters:server:stop', function(id)
    TriggerClientEvent("mh-hunters:client:stopHunt", id)
end)

RegisterNetEvent('police:server:policeAlert', function(text)
    local src = source
    local count = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v and v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            count = count + 1
        end
    end
    if count == 0 then
        TriggerClientEvent("mh-hunters:client:startHunt", src, math.random(2, 4))
    end
end)
