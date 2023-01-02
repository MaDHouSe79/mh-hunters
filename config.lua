--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

Config = {}
Config.Job = 'police' -- police job
Config.WaitTime = 60000 -- a wait timer before the hunters will spawn and chase (5 secs) 

Config.UseCars = true -- true if you want hunter cars.
Config.UseBikes = true -- true if you want hunter bikes.
Config.UseHelikopters = false


Config.MinVehicleSpawn = 2 -- min vehicles to spawn (don't go to high, you will get a network overflow)
Config.MaxVehicleSpawn = 4 -- max vehicles to spawn (don't go to high, you will get a network overflow)

Config.AutoActivedOnCrime = true -- activate when doing a crime, this can be slap or kill other peds
Config.EnableIfNoCopsOnline = true -- enable hunters when there is are no cops online.

Config.Models      = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03"}
Config.Bikes       = {"sanchez", "sanchez2", "akuma", "carbonrs", "bagger", "daemon"}
Config.Vehicles    = {"vacca", "jester", "buffalo", "carbonizzare", "comet2", "dominator", "feltzer2", "fusilade"}
Config.Helikopters = {"buzzard", "buzzard2", "annihilator", "maverick", "savage"}
Config.Weapons     = {"WEAPON_PISTOL", "WEAPON_PISTOL_MK2", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_STUNGUN"}