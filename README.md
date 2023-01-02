<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
  <a href="https://github.com/MaDHouSe79/mh-intercom/issues">
    <img src="https://img.shields.io/github/issues/MaDHouSe79/mh-hunters"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-intercom/watchers">
    <img src="https://img.shields.io/github/watchers/MaDHouSe79/mh-hunters"/> 
  </a> 
  <a href="https://github.com/MaDHouSe79/mh-hunters/network/members">
    <img src="https://img.shields.io/github/forks/MaDHouSe79/mh-hunters"/> 
  </a>  
  <a href="https://github.com/MaDHouSe79/mh-hunters/stargazers">
    <img src="https://img.shields.io/github/stars/MaDHouSe79/mh-hunters?color=white"/> 
  </a>
  <a href="https://github.com/MaDHouSe79/mh-hunters/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/MaDHouSe79/mh-hunters?color=black"/> 
  </a>      
</p>

<p align="center">
  <img alig src="https://github-profile-trophy.vercel.app/?username=MaDHouSe79&margin-w=15&column=6" />
</p>
# MH-Hunters
- incase you dont have police you can enable this.

# what this script does is,
it auto send hunters to a player that just did a crime.
you need to edit some script in your system to make this work.

# Commands
- /startHunt [id] (admin only)
- /stopHunt [id]  (admin only)


# qb-storerobbery example
- add this in the qb-storerobbery config.lua
```lua
Config.UseHuntersIfNoCopsOnline = true -- set to false if you don't want to use the hunters ;)
```
# To change in client side
```lua
CreateThread(function()
    while true do
        Wait(1)
        local inRange = false
        if QBCore ~= nil then
            local pos = GetEntityCoords(PlayerPedId())
            for safe,_ in pairs(Config.Safes) do
                local dist = #(pos - Config.Safes[safe][1].xyz)
                if dist < 3 then
                    inRange = true
                    if dist < 1.0 then
                        if not Config.Safes[safe].robbed then
                            DrawText3Ds(Config.Safes[safe][1].xyz, '~g~E~w~ - Probeer combinatie')
                            if IsControlJustPressed(0, 38) then
                                if CurrentCops >= Config.MinimumStoreRobberyPolice then
                                    currentSafe = safe
                                    if math.random(1, 100) <= 65 and not IsWearingHandshoes() then
                                        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                                    end
                                    if math.random(100) <= 50 then
                                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                                    end
                                    if Config.Safes[safe].type == "keypad" then
                                        SendNUIMessage({
                                            action = "openKeypad",
                                        })
                                        SetNuiFocus(true, true)
                                    else
                                        QBCore.Functions.TriggerCallback('qb-storerobbery:server:getPadlockCombination', function(combination)
                                            TriggerEvent("SafeCracker:StartMinigame", combination)
                                        end, safe)
                                    end

                                    if not copsCalled then
                                        local pos = GetEntityCoords(PlayerPedId())
					                    local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                        local street1 = GetStreetNameFromHashKey(s1)
                                        local street2 = GetStreetNameFromHashKey(s2)
                                        local streetLabel = street1
                                        if street2 ~= nil then
                                            streetLabel = streetLabel .. " " .. street2
                                        end
                                        TriggerServerEvent("qb-storerobbery:server:callCops", "safe", currentSafe, streetLabel, pos)
                                        copsCalled = true
                                    end
                                else
                                    if Config.UseHuntersIfNoCopsOnline then
                                        currentSafe = safe
                                        if math.random(1, 100) <= 65 and not IsWearingHandshoes() then
                                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                                        end
                                        if math.random(100) <= 50 then
                                            TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                                        end
                                        if Config.Safes[safe].type == "keypad" then
                                            SendNUIMessage({
                                                action = "openKeypad",
                                            })
                                            SetNuiFocus(true, true)
                                        else
                                            QBCore.Functions.TriggerCallback('qb-storerobbery:server:getPadlockCombination', function(combination)
                                                TriggerEvent("SafeCracker:StartMinigame", combination)
                                            end, safe)
                                        end

                                        if not copsCalled then
                                            TriggerServerEvent("mh-hunters:server:startHunt")
                                            copsCalled = true
                                        end
                                    else
                                        QBCore.Functions.Notify("Niet genoeg politie (".. Config.MinimumStoreRobberyPolice .." Vereist)", "error")
                                    end
                                end
                            end
                        else
                            DrawText3Ds(Config.Safes[safe][1].xyz, 'Kluis geopend')
                        end
                    end
                end
            end
        end
        if not inRange then
            Wait(2000)
        end
    end
end)
```
```lua
RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    usingAdvanced = isAdvanced
    for k, v in pairs(Config.Registers) do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - Config.Registers[k][1].xyz)
        if dist <= 1 and not Config.Registers[k].robbed then
            if CurrentCops >= Config.MinimumStoreRobberyPolice then
                if usingAdvanced then
                    lockpick(true)
                    currentRegister = k
                    if not IsWearingHandshoes() then
                        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                    end
                    if not copsCalled then
			            local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                        local street1 = GetStreetNameFromHashKey(s1)
                        local street2 = GetStreetNameFromHashKey(s2)
                        local streetLabel = street1
                        if street2 ~= nil then
                            streetLabel = streetLabel .. " " .. street2
                        end
                        TriggerServerEvent("qb-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                        copsCalled = true
                    end
                else
                    lockpick(true)
                    currentRegister = k
                    if not IsWearingHandshoes() then
                        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                    end
                    if not copsCalled then
			            local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                        local street1 = GetStreetNameFromHashKey(s1)
                        local street2 = GetStreetNameFromHashKey(s2)
                        local streetLabel = street1
                        if street2 ~= nil then
                            streetLabel = streetLabel .. " " .. street2
                        end
                        TriggerServerEvent("qb-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                        copsCalled = true
                    end
                end
            else
                if Config.UseHuntersIfNoCopsOnline then
                    if usingAdvanced then
                        lockpick(true)
                        currentRegister = k
                        if not IsWearingHandshoes() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        end
                        if not copsCalled then
                            TriggerServerEvent("mh-hunters:server:startHunt")
                            copsCalled = true
                        end
                    else
                        lockpick(true)
                        currentRegister = k
                        if not IsWearingHandshoes() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        end
                        if not copsCalled then
                            TriggerServerEvent("mh-hunters:server:startHunt")
                            copsCalled = true
                        end
                    end
                else
                    QBCore.Functions.Notify("Niet genoeg Politie (2 vereist)", "error")
                end
            end
        end
    end
end)
```

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
