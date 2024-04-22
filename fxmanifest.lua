fx_version 'cerulean'
game 'gta5'

description 'sg-container'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/shared.lua',
    'locales/*.lua',
}

client_script {
    'bridge/client/*.lua',
    'config/client.lua',
    'client/main.lua'

}
server_script {
    'bridge/server/*.lua',
    'server/main.lua'
}

files {
    'bridge/modules/*.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
