--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local hunters = {}
local blips = {}
local spawnRadius = 250
local hasNotify = false
local huntingTimer = Config.HuntingTime
local bypass = false
local isActive = false
local count = 0

local function GetDistance(pos1, pos2)
    return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
end

local function DeleteHunters()
    for i = 1, #hunters do
        if hunters[i] then
            if hunters[i].driver ~= nil then
                if DoesEntityExist(hunters[i].driver) then
                    DeleteEntity(hunters[i].driver)
                    hunters[i].driver = nil
                end
            end
            if hunters[i].codriver ~= nil then
                if DoesEntityExist(hunters[i].codriver) then
                    DeleteEntity(hunters[i].codriver)
                    hunters[i].codriver = nil
                end
            end
            if hunters[i].vehicle ~= nil then
                if DoesEntityExist(hunters[i].vehicle) then
                    DeleteEntity(hunters[i].vehicle)
                    hunters[i].vehicle = nil
                end
            end
            if hunters[i].driver == nil and hunters[i].codriver == nil and hunters[i].vehicle == nil then
                hunters[i] = nil
            end
        end
    end
    QBCore.Functions.Notify(Lang:t('info.you_lose_the_hunters'))
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
                                if GetDistance(GetEntityCoords(hunters[i].driver), GetEntityCoords(PlayerPedId())) > Config.MinLoseHuntersDistance then
                                    DeleteEntity(hunters[i].driver)
                                    hunters[i].driver = nil
                                    QBCore.Functions.Notify(Lang:t('info.you_lose_a_hunter')) 
                                else
                                    alive = alive + 1
                                end
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
                                if GetDistance(GetEntityCoords(hunters[i].codriver), GetEntityCoords(PlayerPedId())) > Config.MinLoseHuntersDistance then
                                    DeleteEntity(hunters[i].codriver)
                                    hunters[i].codriver = nil
                                    QBCore.Functions.Notify(Lang:t('info.you_lose_a_hunter')) 
                                else
                                    alive = alive + 1
                                end
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
            end
        end
    end
    return alive
end

local function SetPedOutfit(ped)
    local data = Config.Outfit
    local hearTexture = math.random(1,5)
    local hearItem = math.random(1,2)
    if data["hair"] ~= nil then SetPedComponentVariation(ped, 2, hearItem, hearTexture, 0) end
    if data["beard"] ~= nil then SetPedComponentVariation(ped, 1, data["beard"].item, data["hair"].texture, 0) end
    if data["pants"] ~= nil then SetPedComponentVariation(ped, 4, data["pants"].item, data["pants"].texture, 0) end
    if data["arms"] ~= nil then SetPedComponentVariation(ped, 3, data["arms"].item, data["arms"].texture, 0) end
    if data["t-shirt"] ~= nil then SetPedComponentVariation(ped, 8, data["t-shirt"].item, data["t-shirt"].texture, 0) end
    if data["vest"] ~= nil then SetPedComponentVariation(ped, 9, data["vest"].item, data["vest"].texture, 0) end
    if data["torso2"] ~= nil then SetPedComponentVariation(ped, 11, data["torso2"].item, data["torso2"].texture, 0) end
    if data["shoes"] ~= nil then SetPedComponentVariation(ped, 6, data["shoes"].item, data["shoes"].texture, 0) end
    if data["bag"] ~= nil then SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0) end
    if data["decals"] ~= nil then SetPedComponentVariation(ped, 10, data["decals"].item, data["decals"].texture, 0) end
    if data["mask"] ~= nil then SetPedComponentVariation(ped, 1, data["mask"].item, data["mask"].texture, 0) end
    if data["bag"] ~= nil then SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0) end
    if data["hat"] ~= nil and data["hat"].item ~= -1 and data["hat"].item ~= 0 then SetPedPropIndex(ped, 0, data["hat"].item, data["hat"].texture, true) end
    if data["glass"] ~= nil and data["glass"].item ~= -1 and data["glass"].item ~= 0 then SetPedPropIndex(ped, 1, data["glass"].item, data["glass"].texture, true) end
    if data["ear"] ~= nil and data["ear"].item ~= -1 and data["ear"].item ~= 0 then SetPedPropIndex(ped, 2, data["ear"].item, data["ear"].texture, true) end
end

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
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
    if Config.UseCustumPedModel then model = Config.CustumPedModel end
    loadModel(model)
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, 0, true, true)
    GiveWeaponToPed(ped, Config.Weapons[math.random(1, #Config.Weapons)], 999, false, true)
    SetPedIntoVehicle(ped, vehicle, seat)
    SetPedOutfit(ped)
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
    SetPedSeeingRange(ped, 150.0)
    SetPedHearingRange(ped, 150.0)
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
    SetModelAsNoLongerNeeded(model)
    CreateBountyBlip(vehicle, "HUNTER", coords)
    return vehicle
end

local function HelikopterChase(pilot, copilot, helikopter)
    CreateThread(function()
        while true do
            local sleep = 10
            if isActive and not bypass then
                if (pilot and helikopter) then
                    TaskHeliChase(pilot, PlayerPedId(), 0, 0, 50.0)
                    TaskCombatPed(pilot, PlayerPedId(), 0, 16)
		    if Config.HelikopterCanShoot then
                        SetVehicleShootAtTarget(pilot, PlayerPedId())
                    end
                    if copilot ~= nil then
                        TaskCombatPed(copilot, PlayerPedId(), 0, 16)
			if Config.HelikopterCanShoot then
                            SetVehicleShootAtTarget(copilot, PlayerPedId())
                        end
                    end
                    sleep = 1000
                end
            end
	    if not isActive and (pilot and helikopter) and not bypass then
                local flytoPoint = vector3(-408.47, 1206.16, 325.64) 
                TaskHeliMission(pilot, helikopter, 0, 0, flytoPoint.x, flytoPoint.y, flytoPoint.z, 4, 500.0, -1.0, -1.0, 10, 10, 5.0, 0)
                sleep = 500
            end
            Wait(sleep)
        end
    end)
end

local function Chase(driver, codriver, vehicle)
    CreateThread(function()
        while true do
            local sleep = 10
            if isActive and not bypass then
                local coords = GetEntityCoords(PlayerPedId())
                local vehicle_coords = GetEntityCoords(vehicle)
                local driver_coords = GetEntityCoords(driver)
                local distance = GetDistance(vehicle_coords, coords)
                if distance < 50 then
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
                if IsEntityDead(driver) then 
                    DeleteEntity(driver) 
                    driver = nil 
                end
                if codriver ~= nil and IsEntityDead(codriver) then 
                    DeleteEntity(codriver) 
                    codriver = nil 
                end
                if driver == nil and codriver == nil then
                    DeleteEntity(vehicle) 
                end
                sleep = 500
            end
            Wait(sleep)
        end
    end)
end

local function spawnHelikopters()
    if Config.UseHelikopters then
        for i = 1, 2 do
            local model = Config.Helikopters[math.random(1, #Config.Helikopters)]
            local coords = GetEntityCoords(PlayerPedId())
            local _, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-spawnRadius, spawnRadius), coords.y + math.random(-spawnRadius, spawnRadius), coords.z + 100, 1, 3.0, 0)
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

local function spawnVehicles(amount)
    if Config.UseCars then
        for i = 1, amount do
            local model = Config.Vehicles[math.random(1, #Config.Vehicles)]
            local coords = GetEntityCoords(PlayerPedId())
            local _, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-spawnRadius, spawnRadius), coords.y + math.random(-spawnRadius, spawnRadius), coords.z, 1, 3.0, 0)
            local vehicle = createVehicle(model, spawnPos, spawnHeading)
            local driver = createPed(spawnPos, vehicle, -1)
            hunters[#hunters + 1] = {driver = driver, codriver = nil, vehicle = vehicle}
            Chase(driver, codriver, vehicle)
            Wait(100)
        end
    end
end

local function spawnBikes(amount)
    if Config.UseBikes then
        for i = 1, amount do
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
    count = 0
    spawnRadius = 250
    huntingTimer = Config.HuntingTime
    DeletePedsAndCars()
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

local function Start(amount)
    Wait(Config.WaitTime)
    huntingTimer = Config.HuntingTime
    QBCore.Functions.Notify(Lang:t('info.hunters_called'))
    if Config.UseBikes then spawnBikes(amount) end
    if Config.UseCars then spawnVehicles(amount) end
    if Config.UseHelikopters then spawnHelikopters() end
    isActive = true
end

local function Stop()
    isActive = false
    hasNotify = false
    count = 0
    hunters = {}
    blips = {}
    spawnRadius = 250
    huntingTimer = Config.HuntingTime
    Reset()
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        if LocalPlayer.state.isLoggedIn then
            local victim, attacker, isDead, weapon = data[1], data[2], data[4], data[7]
            local count = HowManyHuntersAreStillAlive()
            if victim == PlayerPedId() then return end
            if not isActive and count <= 0 and not bypass then
                local entityType = GetEntityType(victim)
                if entityType == 3 then return end
                if entityType == 1 then
                    if IsPedHuman(victim) and GetEntityHealth(victim) <= 0 then
                        if attacker == PlayerPedId() and not hasNotify then
                            if not QBCore.Functions.GetPlayerData().metadata['isdead'] or not QBCore.Functions.GetPlayerData().metadata['inlaststand'] then
                                hasNotify = true
                                if Config.PedAttackCallHunters then
                                    TriggerServerEvent("mh-hunters:server:start", math.random(Config.MinHunters, Config.MaxHunters))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Stop()
    end
end)

RegisterNetEvent('mh-hunters:client:startHunt', function(amount, cops)
    if not bypass then
        if cops >= 1 then
            QBCore.Functions.Notify(Lang:t('info.can_not_call_hunters'))
        else
            Start(amount)
        end
    end
end)

RegisterNetEvent('mh-hunters:client:stopHunt', function()
    Stop()
end)

RegisterNetEvent('mh-hunters:client:bypassEnable', function()
    bypass = true
end)

RegisterNetEvent('mh-hunters:client:bypassDisable', function()
    bypass = false
end)

CreateThread(function()
	while true do
        local sleep = 1000
        if LocalPlayer.state.isLoggedIn then
            if isActive and not bypass then
                if QBCore.Functions.GetPlayerData().metadata['isdead'] then
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
        if isActive and not bypass then
            sleep = 5
            if count > 1 then DrawTxt(0.93, 1.44, 1.0,1.0,0.6, Lang:t('info.hunters_alive', {count = count}), 255, 255, 255, 255) end
            if count == 1 then DrawTxt(0.93, 1.44, 1.0,1.0,0.6, Lang:t('info.hunter_alive', {count = count}), 255, 255, 255, 255) end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
	while true do
        if isActive and not bypass then
            if huntingTimer > 0 then huntingTimer = huntingTimer - 1 end
            if huntingTimer <= 0 then huntingTimer = 0 end
            if huntingTimer == 0 then 
                isActive = false
                DeleteHunters() 
            end
        end
        Wait(1000)
    end
end)
