--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local hunters = {}
local blips = {}
local hasNotify = false
local isActive = false
local count = 0
local spawncount = 0
local spawnRadius = 250

local function DeletePedsAndCars()
    if #hunters > 0 then
        for _, v in pairs(hunters) do
            SetEntityAsMissionEntity(v.vehicle, true, true)
            if v.driver ~= nil then 
                ClearPedTasks(v.driver)
                SetPedIntoVehicle(v.driver, v.vehicle, -1)
                TaskVehicleDriveWander(v.driver, v.vehicle, 17.0, 524863)
            end
            if v.codriver ~= nil then
                 ClearPedTasks(v.codriver)
                if v.driver ~= nil then
                    TaskVehicleDriveWander(v.driver, v.vehicle, 17.0, 524863)
                    SetPedIntoVehicle(v.codriver, v.vehicle, 0) 
                else
                    TaskVehicleDriveWander(v.codriver, v.vehicle, 17.0, 524863)
                    SetPedIntoVehicle(v.codriver, v.vehicle, -1)
                end
            end
            SetEntityAsNoLongerNeeded(v.vehicle)
            SetPedAsNoLongerNeeded(v.driver)
            if v.codriver ~= nil then SetPedAsNoLongerNeeded(v.codriver) end
        end
        Wait(25000)
        for _, v in pairs(hunters) do
            if v.driver ~= nil then DeleteEntity(v.driver) end
            if v.codriver ~= nil then DeleteEntity(v.codriver) end
            if v.vehicle ~= nil then DeleteEntity(v.vehicle) end
        end
    end
    if #blips > 0 then
        for _, blip in pairs(blips) do
            RemoveBlip(blip)
        end
    end
    blips = {}
    hunters = {}
end

local function Reset()
    isActive = false
    hasNotify = false
    spawncount = 0
    DeletePedsAndCars()
end

local function GetDistance(pos1, pos2)
    return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
end

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
end

local function HowManyHuntersAreStillAlive()
    local alive = 0
    if #hunters > 0 then
        for i = 1, #hunters do
            if hunters[i] then
                if hunters[i].driver ~= nil then
                    if DoesEntityExist(hunters[i].driver) then
                        if IsEntityAPed(hunters[i].driver) then
                            if IsEntityDead(hunters[i].driver) then
                                DeleteEntity(hunters[i].driver)
                                hunters[i].driver = nil
                            else
                                alive = alive + 1
                            end
                        end
                    end
                end
                if hunters[i].codriver ~= nil then
                    if DoesEntityExist(hunters[i].codriver) then
                        if IsEntityAPed(hunters[i].codriver) then
                            if IsEntityDead(hunters[i].codriver) then
                                DeleteEntity(hunters[i].codriver)
                                hunters[i].codriver = nil
                            else
                                alive = alive + 1
                            end 
                        end
                    end
                end
                if hunters[i].vehicle ~= nil then
                    if DoesEntityExist(hunters[i].vehicle) then
                        if hunters[i].driver == nil and hunters[i].codriver == nil then
                            DeleteEntity(hunters[i].vehicle)
                        end
                    end
                end
                if hunters[i].driver == nil and hunters[i].codriver == nil and hunters[i].vehicle == nil then
                    hunters[i] = nil
                end
                TriggerServerEvent('mh-hunters:server:update', alive)
            end
        end
    end
    return alive
end

local function DrawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

local function CreateBountyBlip(entity, label, location)
    local blip = GetBlipFromEntity(entity)
    if not DoesBlipExist(blip) then
        blip = AddBlipForEntity(entity)
        SetBlipSprite(blip, 161)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(label)
        EndTextCommandSetBlipName(blip)
        blips[#blips + 1] = blip
    end
    if GetBlipFromEntity(PlayerPedId()) == blip then
        RemoveBlip(blip)
    end
end

local function createPed(coords, vehicle, seat)
    local model = Config.Models[math.random(1, #Config.Models)]
    loadModel(model)
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, 0, true, true)
    GiveWeaponToPed(ped, Config.Weapons[math.random(1, #Config.Weapons)], 999, false, true)
    SetPedIntoVehicle(ped, vehicle, seat)
    SetEntityHealth(ped, 250)
    SetPedArmour(ped, 100)
    SetPedAsCop(ped, true)
    SetPedKeepTask(ped, true)
    SetPedAccuracy(ped, 50)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetCanAttackFriendly(ped, false, true)
    SetPedCanSwitchWeapon(ped, true)
    SetPedCombatAbility(ped, 100)
    SetPedCombatMovement(ped, 3)
    SetPedCombatRange(ped, 2)
    SetPedCombatAttributes(ped, 46, true)
    SetPedSeeingRange(ped, 250.0)
    SetPedHearingRange(ped, 250.0)
    SetPedAlertness(ped, 3)
    return ped
end

local function createVehicle(model, coords, heading)
    loadModel(model)
    ClearAreaOfVehicles(coords, 10000, false, false, false, false, false)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)
    SetVehicleNumberPlateText(vehicle, "B-HUNTER")
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleDirtLevel(vehicle, 0)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(model)
    CreateBountyBlip(vehicle, "B-HUNTER", coords)
    return vehicle
end

local function HelikopterChase(pilot, copilot, helikopter)
    CreateThread(function()
        while true do
            local sleep = 10
            if (pilot and helikopter) and IsActive then
                TaskHeliChase(pilot, PlayerPedId(), 0, 0, 50.0)
                TaskCombatPed(pilot, PlayerPedId(), 0, 16)
                TaskCombatPed(copilot, PlayerPedId(), 0, 16)
                sleep = 1000
            end
            Wait(sleep)
        end
    end)
end

local function Chase(driver, codriver, vehicle)
    CreateThread(function()
        while true do
            local sleep = 10
            if isActive then
                local coords = GetEntityCoords(PlayerPedId())
                local vehicle_coords = GetEntityCoords(vehicle)
                local driver_coords = GetEntityCoords(driver)
                local distance = GetDistance(vehicle_coords, coords)
                if distance < 80 then
                    if DoesEntityExist(driver) then 
                        TaskGoToCoordAnyMeans(driver, coords, 2.0, 0, 0, 786603, 0xbf800000) 
                    end
                    if codriver ~= nil and DoesEntityExist(codriver) then 
                        TaskGoToCoordAnyMeans(codriver, coords, 2.0, 0, 0, 786603, 0xbf800000)
                    end
                else
                    if DoesEntityExist(driver) then
                        SetPedIntoVehicle(driver, vehicle, -1)
                        if DoesEntityExist(codriver) then 
                            SetPedIntoVehicle(codriver, vehicle, 0) 
                        end
                        TaskVehicleDriveToCoord(driver, vehicle, coords.x, coords.y, coords.z, 100.0, 1.0, vehicle, 537133628, 1.0, true)
                    else
                        if DoesEntityExist(codriver) then 
                            SetPedIntoVehicle(codriver, vehicle, -1) 
                        end
                        TaskVehicleDriveToCoord(codriver, vehicle, coords.x, coords.y, coords.z, 100.0, 1.0, vehicle, 537133628, 1.0, true)
                    end
                end
                if DoesEntityExist(driver) then 
                    TaskCombatPed(driver, PlayerPedId(), 0, 16) 
                end
                if DoesEntityExist(codriver) then 
                    TaskCombatPed(codriver, PlayerPedId(), 0, 16) 
                end
                sleep = 1000
            end
            Wait(sleep)
        end
    end)
end

local function SpawnHelikopters()
    if Config.UseHelikopters then
        for i = 1, 2 do
            local model = Config.Helikopters[math.random(1, #Config.Helikopters)]
            local coords = GetEntityCoords(PlayerPedId())
            local _, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-spawnRadius, spawnRadius), coords.y + math.random(-spawnRadius, spawnRadius), coords.z + 80, 1, 3.0, 0)
            local helikopter = createVehicle(model, spawnPos, spawnHeading)
            SetHeliBladesFullSpeed(helikopter)
            SetHeliBladesSpeed(helikopter, 100)
            local pilot = createPed(spawnPos, helikopter, -1)
            local copilot = createPed(spawnPos, helikopter, 0)
            hunters[#hunters + 1] = {driver = pilot, codriver = copilot, vehicle = helikopter}
            HelikopterChase(pilot, copilot, helikopter)
            Wait(100)
        end
    end
end

local function spawnVehicles()
    if Config.UseCars and spawncount > 0 and spawncount < 10 then
        for i = 1, spawncount do
            local model = Config.Vehicles[math.random(1, #Config.Vehicles)]
            local coords = GetEntityCoords(PlayerPedId())
            local _, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-spawnRadius, spawnRadius), coords.y + math.random(-spawnRadius, spawnRadius), coords.z, 1, 3.0, 0)
            local vehicle = createVehicle(model, spawnPos, spawnHeading)
            local driver = createPed(spawnPos, vehicle, -1)
            local codriver = createPed(spawnPos, vehicle, 0)
            hunters[#hunters + 1] = {driver = driver, codriver = codriver, vehicle = vehicle}
            Chase(driver, codriver, vehicle)
            Wait(100)
        end
    end
end

local function spawnBikes()
    if Config.UseBikes and spawncount > 0 and spawncount < 10 then
        for i = 1, spawncount do
            local model = Config.Bikes[math.random(1, #Config.Bikes)]
            local coords = GetEntityCoords(PlayerPedId())
            local _, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-spawnRadius, spawnRadius), coords.y + math.random(-spawnRadius, spawnRadius), coords.z + 50.0, 1, 3.0, 0)
            local bike = createVehicle(model, spawnPos, spawnHeading)
            local driver = createPed(spawnPos, bike, -1)
            hunters[#hunters + 1] = {driver = driver, codriver = nil, vehicle = bike}
            Chase(driver, nil, bike)
            Wait(100)
        end
    end
end

local function Start()
    Wait(Config.WaitTime) -- 1 min
    if Config.UseBikes then spawnBikes() end
    if Config.UseCars then spawnVehicles() end
    if Config.UseHelikopters then SpawnHelikopters() end
    isActive = true
end

local function Stop()
    isActive = false
    TriggerServerEvent('mh-hunters:server:stopHunt')
    Reset()
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent("mh-hunters:server:onjoin")
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if isActive then
        TriggerServerEvent("mh-hunters:server:combatLogging")
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        isActive = false
        TriggerServerEvent("mh-hunters:server:onjoin")
    end
end)

AddEventHandler('gameEventTriggered', function(event, bounty)
    if event == "CEventNetworkEntityDamage" then
        if LocalPlayer.state.isLoggedIn and Config.AutoActivedOnCrime then
            local victim, attacker, isDead, weapon = bounty[1], bounty[2], bounty[4], bounty[7]
            count = HowManyHuntersAreStillAlive()
            if not isActive and count == 0 then
                if attacker == PlayerPedId() and not hasNotify and IsEntityAPed(victim) then
                    if not QBCore.Functions.GetPlayerData().metadata['isdead'] or not QBCore.Functions.GetPlayerData().metadata['inlaststand'] then
                        hasNotify = true
                        TriggerServerEvent('mh-hunters:server:startHunt')
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('mh-hunters:client:startHunt', function(amount)
    if amount > 10 then amount = 10 end
    if not Config.EnableIfNoCopsOnline then
        QBCore.Functions.TriggerCallback("mh-hunters:server:CountOnlinePolice", function(count)
            if count <= 0 then
                spawncount = math.floor(amount / 2)
                QBCore.Functions.Notify(Lang:t('info.hunters_called'))
                Start() 
            end
        end)
    else
        spawncount = math.floor(amount / 2)
        QBCore.Functions.Notify(Lang:t('info.hunters_called'))
        Start()
    end
end)

RegisterNetEvent('mh-hunters:client:stopHunt', function()
    Stop()
end)

CreateThread(function()
	while true do
        local sleep = 1000
        if LocalPlayer.state.isLoggedIn then
            if isActive then
                if QBCore.Functions.GetPlayerData().metadata['isdead'] or QBCore.Functions.GetPlayerData().metadata['inlaststand'] then
                    Reset()
                else
                    count = HowManyHuntersAreStillAlive()
                    if count <= 0 then Reset() end
                end
                sleep = 100
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
	while true do
        local sleep = 1000
        if isActive then
            sleep = 5
            DrawTxt(0.93, 1.44, 1.0,1.0,0.6, Lang:t('info.hunters_alive', {count = count}), 255, 255, 255, 255)
        end
        Wait(sleep)
    end
end)
