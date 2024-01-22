fx_version 'cerulean'
game 'gta5'

name 'SimpleHUD'
author 'SimpleDevelopments'
description 'A Simple hud GUI made to work with SimplePriorities'
version '1.0.4'
lua54 'yes'


files {
    'postals.json'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua',
    'server/versionChecker.lua'
}

shared_scripts {
    'config.lua',
}

exports {
    "getAOP",
    "getPostal"
}

server_exports {
    "getPostal"
}


provide "nearest-postal"