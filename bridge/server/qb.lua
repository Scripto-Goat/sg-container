local SharedConfig = require 'config.shared'
if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()
local ox_inv = GetResourceState('ox_inventory') == 'started'

function GetPlayer(id)
    return QBCore.Functions.GetPlayer(id)
end

-- Notifications

function Notify(title, msg, type)
    if type == 'success' then

        if SharedConfig.Notify == 'okok' then
            TriggerClientEvent('okokNotify:Alert', source, title, msg, 3000, 'success', true)
        elseif SharedConfig.Notify == 'ox' then
            TriggerClientEvent('ox_lib:notify', source, 
            {
                title = title,
                description = msg,
                type = 'success'
            })
        elseif SharedConfig.Notify == 'mythic' then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = msg})
        elseif SharedConfig.Notify == 'qb' then
            QBCore.Functions.Notify({
                text = title,
                caption = msg,
            }, 'success', 3000)
        end

elseif type == 'error' then

    if SharedConfig.Notify == 'okok' then
        TriggerClientEvent('okokNotify:Alert', source, title, msg, 3000, 'error', true)
    elseif SharedConfig.Notify == 'ox' then
        TriggerClientEvent('ox_lib:notify', source, 
        {
            title = title,
            description = msg,
            type = 'error'
        })
    elseif SharedConfig.Notify == 'mythic' then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = msg})
    elseif SharedConfig.Notify == 'qb' then
        TriggerClientEvent('QBCore:Notify', source, {text = title, caption = msg}, 'error')
    end
    end
    
end

function AddItem(Player, item, amount)
    if ox_inv then 
        local canCarry = exports.ox_inventory:CanCarryItem(source, item, amount)
        if canCarry then
            exports.ox_inventory:AddItem(Player.PlayerData.source, item, amount)
        else
            print('You cannot carry this!')
        end
    else
        Player.Functions.AddItem(item, amount)
    end
end

function RemoveItem(Player, item, amount)
    Player.Functions.RemoveItem(item, amount)
end

function AddMoney(Player, moneyType, amount)
    Player.Functions.AddMoney(moneyType, amount)
end

function RemoveMoney(Player, moneyType, amount)
    Player.Functions.RemoveMoney(moneyType, amount)
end

function itemCount(Player, item, amount)
    local count = 0
    if ox_inv then 
        count = exports.ox_inventory:GetItemCount(Player.PlayerData.source, item)
    else
        for slot, data in pairs(Player.PlayerData.items) do -- Apparently qb only counts the amount from the first slot so I gotta do this.
            if data.name == item then
                count += data.amount
            end
        end
    end
    return count >= amount
end

-- Function use to count number of players with job are online
--- @param jobName table
PlayersWithJob = function(jobName)
    if not jobName then return end
    local jobCount = 0
        for _, players in pairs(QBCore.Functions.GetPlayers()) do
            local player = QBCore.Functions.GetPlayer(players)
            local job = player.PlayerData.job
            for _, jobs in pairs(jobName) do
                local jobNames = jobs
                if job.name == jobNames then
                    jobCount = jobCount + 1
                end
            end
        end

    return jobCount
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    ServerOnLogout(source)
end)