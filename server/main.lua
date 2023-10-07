--[[ ===================================================== ]] --
--[[           MH AI Hunters Script by MaDHouSe            ]] --
--[[ ===================================================== ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local isbusy = false

local function CountCops()
    local online = 0
    for k, id in pairs(QBCore.Functions.GetPlayers()) do
        local target = QBCore.Functions.GetPlayer(id)
        if target.PlayerData.job.name == "police" and target.PlayerData.job.onduty then
            online = online + 1
        end
    end
    return online
end

QBCore.Commands.Add("startHunt", "", {}, false, function(source, args)
    if args[1] and tonumber(args[1]) > 0 then
        local id = tonumber(args[1])
        local amount = tonumber(args[2])
        if amount > Config.MaxVehicleSpawn then
            amount = Config.MaxVehicleSpawn
        end
        if Config.UseHunters then
            TriggerClientEvent("mh-hunters:client:startHunt", id, amount, 0)
        end
    end
end, 'admin')

QBCore.Commands.Add("stopHunt", "", {}, false, function(source, args)
    if args[1] and tonumber(args[1]) > 0 then
        local id = tonumber(args[1])
        isbusy = false
        TriggerClientEvent("mh-hunters:client:stopHunt", id)
    end
end, 'admin')

RegisterServerEvent('mh-hunters:server:start')
AddEventHandler('mh-hunters:server:start', function(amount)
    local src = source
    if Config.EnableIfNoCopsOnline and not isbusy then
        isbusy = true
        TriggerClientEvent("mh-hunters:client:startHunt", src, amount, CountCops())
    else
        if Config.UseHunters and not isbusy then
            isbusy = true
            TriggerClientEvent("mh-hunters:client:startHunt", src, amount, 0)
        end
    end
end)

RegisterServerEvent('mh-hunters:server:stop')
AddEventHandler('mh-hunters:server:stop', function(id)
    isbusy = false
    TriggerClientEvent("mh-hunters:client:stopHunt", id)
end)

RegisterNetEvent('police:server:policeAlert', function(text)
    local src = source
    local count = CountCops()
    if Config.EnableIfNoCopsOnline and Config.UseHunters and count == 0 then
        TriggerClientEvent("mh-hunters:client:startHunt", src, math.random(Config.MinHunters, Config.MaxHunters), count)
    end
end)
