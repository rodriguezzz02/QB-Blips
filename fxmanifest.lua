fx_version 'cerulean'
game 'gta5'

author 'TuNombre'
description 'QB Blip Manager persistente con ox_lib y oxmysql'
version '2.0.0'

shared_script '@qb-core/import.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_script 'client.lua'

dependencies {
    'qb-core',
    'ox_lib',
    'oxmysql'
}