fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'OpenAI'
description 'Mirage prototype: spawn a decoy runner in the direction the player is facing'
version '1.0.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qb-core'
}
