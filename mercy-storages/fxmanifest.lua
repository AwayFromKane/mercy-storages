fx_version 'cerulean'
game 'gta5'

author 'Razer (#0404)'
description 'Storages'

ui_page {'html/ui.html'}

shared_scripts {
    'shared/sh_*.lua',
}

client_scripts {
    "client/cl_*.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/sv_*.lua"
}

files {
	'html/ui.html',
    'html/css/*.css',
    'html/js/*.js',
}
