fx_version 'cerulean'
game 'gta5'

name 'SimpleHUD'
author 'fadin_laws'
description 'A Simple hud GUI by your minimap to show priorities, location, discord, and more!'
version '1.0.0'
lua54 'yes'

file 'postals.json'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua',
    'server/versionChecker.lua'
}

shared_scripts {
    'config.lua'
}

exports {
    "getAOP",
    "getPostal"
}

server_exports {
    "getPostal"
}

provide "nearest-postal"