-- Configs
local SharedConfig = require 'config.shared'

if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

-- Notifications
function Notify(title, msg, type)
    if type == 'success' then

        if SharedConfig.Notify == 'okok' then
            exports['okokNotify']:Alert(title, msg, 3000, 'success', true)
        elseif SharedConfig.Notify == 'ox' then
            lib.notify({
                title = title,
                description = msg,
                type = 'success'
            })
        elseif SharedConfig.Notify == 'mythic' then
            exports['mythic_notify']:DoHudText('success', msg)
        elseif SharedConfig.Notify == 'qb' then
            QBCore.Functions.Notify({
                text = title,
                caption = msg,
            }, 'success', 3000)
        end

elseif type == 'error' then

    if SharedConfig.Notify == 'okok' then
        exports['okokNotify']:Alert(title, msg, 3000, 'error', true)
    elseif SharedConfig.Notify == 'ox' then
        lib.notify({
            title = title,
            description = msg,
            type = 'error'
        })
    elseif SharedConfig.Notify == 'mythic' then
        exports['mythic_notify']:DoHudText('error', msg)
    elseif SharedConfig.Notify == 'qb' then
        QBCore.Functions.Notify({
            text = title,
            caption = msg,
        }, 'error', 3000)
    end
    end
    
end
