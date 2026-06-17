fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 's_needs'
description 'Hunger & thirst needs for the Saga framework. Server-authoritative, persists via s_core metadata, syncs on the saga:needs statebag.'
author 'ValRavn'
version '0.1.0'

dependencies {
    's_lib',
    's_core',
}

shared_scripts {
    '@s_lib/init.lua',
    'shared/config.lua',
}

server_scripts {
    'server/main.lua',
}
