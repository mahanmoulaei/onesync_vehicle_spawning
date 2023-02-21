fx_version "cerulean"
use_experimental_fxv2_oal "yes"
lua54 "yes"
game "gta5"

description "onesync_spawning_snippet"
version "0.0.0"

dependencies {
    "ox_lib"
}

shared_scripts {
    "shared/*.lua"
}

server_scripts {
    "server/*.lua"
}

client_scripts {
    "client/*.lua",
}