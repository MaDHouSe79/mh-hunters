--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()

local function GetUsername(id)
    local player = QBCore.Functions.GetPlayer(id)
    return player.PlayerData.charinfo.firstname ..' '.. player.PlayerData.charinfo.lastname
end

local function CombatLogging(id)
    print("[CHEATING] "..GetUsername(id).." is Combat Logging...")
end

local function AddToDB(id, amount)
    MySQL.Async.insert('INSERT INTO player_hunters (name, license, amount) VALUES (?, ?, ?)', {
        GetUsername(id), QBCore.Functions.GetIdentifier(id, 'license'), amount
    })
end

local function RemoveFromDB(id)
    MySQL.Async.execute('DELETE FROM player_hunters WHERE license = ?', {QBCore.Functions.GetIdentifier(id, 'license')})
end

local function UpdateDB(id, alive)
    MySQL.Async.execute('UPDATE player_hunters SET amount = ? WHERE license = ?', {alive, QBCore.Functions.GetIdentifier(id, 'license')})
end

local function isPlayerHunted(id)
    local isHunted = false
    local amount = (math.random(Config.MinVehicleSpawn, Config.MaxVehicleSpawn) / 2)
	MySQL.Async.fetchAll("SELECT * FROM player_hunters", {}, function(rs)
		if type(rs) == 'table' and #rs > 0 then
            for i = 1, #rs do
                if rs[i].license == QBCore.Functions.GetIdentifier(id, 'license') then
                    amount = rs[i].amount
                    isHunted = true
                end
            end
            if isHunted then
                if QBCore.Functions.GetDutyCount(Config.job) <= 0 then
                    AddToDB(src, amount)
                    TriggerClientEvent("mh-hunters:client:startHunt", src, amount)
                end
            end
            print(isHunted, amount)
        end
	end)
end

QBCore.Functions.CreateCallback('mh-hunters:server:CountOnlinePolice', function(source, cb)
	cb(QBCore.Functions.GetDutyCount(Config.job))
end)

RegisterNetEvent('mh-hunters:server:startHunt', function()
    local src = source 
    local amount = (math.random(Config.MinVehicleSpawn, Config.MaxVehicleSpawn) / 2)
    --AddToDB(src, amount)
    TriggerClientEvent("mh-hunters:client:startHunt", src, amount)
end)

RegisterNetEvent('mh-hunters:server:stopHunt', function()
    local src = source 
    --RemoveFromDB(src)
end)

RegisterNetEvent('mh-hunters:server:onjoin', function()
    local src = source 
    --isPlayerHunted(src)
end)

RegisterNetEvent('mh-hunters:server:combatLogging', function()
    local src = source 
    CombatLogging(src)
end)

RegisterNetEvent('mh-hunters:server:update', function(alive)
    local src = source 
    --UpdateDB(src, alive)
end)

QBCore.Commands.Add("startHunt", "", {}, false, function(source, args)
    if args[1] and tonumber(args[1]) > 0 then
        local id = tonumber(args[1])
        local amount = Config.MaxVehicleSpawn
        if args[2] and tonumber(args[2]) > Config.MaxVehicleSpawn then
            amount = tonumber(args[2])
        end
        if amount > 10 then amount = 10 end
        TriggerClientEvent("mh-hunters:client:startHunt", id, amount)
    end
end, 'admin')

QBCore.Commands.Add("stopHunt", "", {}, false, function(source, args)
    if args[1] and tonumber(args[1]) > 0 then
        local id = tonumber(args[1])
        TriggerClientEvent("mh-hunters:client:stopHunt", id)
    end
end, 'admin')