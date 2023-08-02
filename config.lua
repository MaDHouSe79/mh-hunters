--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

Config = {}
Config.WaitTime = 5000 --60000       -- a wait timer before the hunters will spawn and chase (1 min) 

Config.EnableIfNoCopsOnline = true   -- enable hunters when no cops are online.

Config.MinLoseHuntersDistance = 1000 -- lose the hunters in a amount of distance.
Config.HuntingTime = 300             -- 300 is 5 min

Config.UseCars = true
Config.UseBikes = true
Config.MaxVehicleSpawn = 3           -- max vehicles to spawn don't ho to height.


Config.PedAttackCallHunters = true   -- if a player attacks a ped the hunters are comming.

Config.Models = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03"}
Config.Bikes = {"sanchez", "sanchez2", "akuma", "carbonrs", "bagger", "daemon"}
Config.Vehicles = {"vacca", "jester", "buffalo", "carbonizzare", "comet2", "dominator", "feltzer2", "fusilade"}
Config.Weapons = {"WEAPON_PISTOL", "WEAPON_PISTOL_MK2", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_STUNGUN"}
