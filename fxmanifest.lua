fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'gldnrmz-elevators'
author 'GLDNRMZ'
description 'Configurable elevators and teleport points with server-side access checks'
version '2.0.0'
repository 'https://github.com/GLDNRMZ/gldnrmz-elevators'

dependencies {
    '/onesync',
    'ox_lib',
    'community_bridge',
}

shared_script '@ox_lib/init.lua'

client_script 'client.lua'
server_script 'server.lua'

files {
    'config.lua',
}
