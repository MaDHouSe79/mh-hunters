--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

Config = {}
Config.WaitTime = 5000 --60000       -- a wait timer before the hunters will spawn and chase (1 min) 

Config.UseHunters = true             -- if you want the hunter enable set this true
Config.EnableIfNoCopsOnline = true   -- enable hunters when no cops are online.

Config.MinLoseHuntersDistance = 1000 -- lose the hunters in a amount of distance.
Config.HuntingTime = 900             -- 300 is 10 min

Config.MinHunters = 2
Config.MaxHunters = 4

Config.UseCars = true
Config.UseBikes = true
Config.UseHelikopters = true 
Config.MaxVehicleSpawn = 3           -- max vehicles to spawn don't ho to height.

Config.HelikopterCanShoot = true     -- if true helikopters can shoot you

Config.PedAttackCallHunters = true   -- if a player attacks a ped the hunters are comming.

Config.Models = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03"}
Config.Bikes = {"sanchez", "sanchez2", "akuma", "carbonrs", "bagger", "daemon"}
Config.Vehicles = {"vacca", "jester", "buffalo", "carbonizzare", "comet2", "dominator", "feltzer2", "fusilade"}
Config.Helikopters = {"buzzard", "buzzard2", "annihilator", "maverick", "savage"}
Config.Weapons = {"WEAPON_PISTOL", "WEAPON_PISTOL_MK2", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_STUNGUN"}

Config.UseCustumPedModel = true
Config.CustumPedModel = "mp_m_freemode_01"
Config.Outfit = {
    ['hair']    = {item = 19, texture = 1}, -- Hear
    ['beard']   = {item = 2, texture = 0},  -- Beard
    ["pants"]   = {item = 56, texture = 0}, -- Pants
    ["arms"]    = {item = 30, texture = 0}, -- Arms
    ["t-shirt"] = {item = 23, texture = 0}, -- T Shirt
    ["vest"]    = {item = 18, texture = 0}, -- Body Vest
    ["torso2"]  = {item = 74, texture = 3}, -- Jacket
    ["shoes"]   = {item = 25, texture = 0}, -- Shoes
    ["decals"]  = {item = 0, texture = 0},  -- Neck Accessory
    ["bag"]     = {item = 0, texture = 0},  -- Bag
    ["hat"]     = {item = 0, texture = 0},  -- Hat
    ["glass"]   = {item = 0, texture = 0},  -- Glasses
    ["mask"]    = {item = 0, texture = 0}   -- Mask
}
