--[[ ===================================================== ]]--
--[[           MH AI Hunters Script by MaDHouSe            ]]--
--[[ ===================================================== ]]--

fx_version 'cerulean'
game 'gta5'

description 'MH - Hunters (AI Hunters)'
author 'MaDHouSe'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'locales/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/update.lua',
}

dependencies {'oxmysql', 'ox_lib'}


lua54 'yes'
