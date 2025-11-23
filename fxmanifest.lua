fx_version 'cerulean'
game 'gta5'

author 'GLDNRMZ'
description 'Elevator Script with ox_lib'
version '1.0.0'

-- Enable Lua 5.4
lua54 'yes'

dependencies {
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'config.lua',
    'client.lua',
}
