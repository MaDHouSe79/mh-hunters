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

# To change in client side qb-policejob/server/main.lua file.
```lua
RegisterNetEvent('police:server:policeAlert', function(text)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    local count = 0
    for _, v in pairs(players) do
        if v and v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            local alertData = {title = Lang:t('info.new_call'), coords = {x = coords.x, y = coords.y, z = coords.z}, description = text}
            TriggerClientEvent("qb-phone:client:addPoliceAlert", v.PlayerData.source, alertData)
            TriggerClientEvent('police:client:policeAlert', v.PlayerData.source, coords, text)
            count = count + 1
        end
    end
    if count == 0 then
        TriggerServerEvent("mh-hunters:server:start", math.random(2, 4))
    end
end)
```

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)
