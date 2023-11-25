fx_version 'cerulean'
game 'gta5'

name 'SimpleHUD'
author 'fadin_laws'
description 'A Simple hud GUI by your minimap to show priorities, location, discord, and more!'
version '1.0.2'
lua54 'yes'


files {
    'postals.json'
}

client_scripts {
    'client/client.lua',
    'client/speedLimit.lua'
}

server_scripts {
    'server/server.lua',
    'server/versionChecker.lua'
}

shared_scripts {
    'Config/config.lua',
    'Config/management.lua',
    'Config/weapons.lua'
}

exports {
    "getAOP",
    "getPostal"
}

server_exports {
    "getPostal"
}


provide "nearest-postal"