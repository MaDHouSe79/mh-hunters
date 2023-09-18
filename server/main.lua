--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()

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
        if amount > Config.MaxVehicleSpawn then amount = Config.MaxVehicleSpawn end
        if Config.UseHunters then TriggerClientEvent("mh-hunters:client:startHunt", id, amount, 0) end
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
        if Config.UseHunters then
            TriggerClientEvent("mh-hunters:client:startHunt", src, amount, 0)
        end
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
        if Config.UseHunters then
            TriggerClientEvent("mh-hunters:client:startHunt", src, math.random(Config.MinHunters, Config.MaxHunters), 0)
        end
    end
end)
