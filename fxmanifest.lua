fx_version 'cerulean'
game 'gta5'
version '1.0.5'
lua54 'yes'
author 'wx / woox'
description 'Advanced report system utilised via OX Lib'

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

files {
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    'configs/*.lua'
}

dependencies = {
    'ox_lib',
    -- 'oxmysql'
}