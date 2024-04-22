local config = require 'config.server'
local sharedConfig = require 'config.shared'
local logger = require 'bridge.modules.logger'
local startedContainer = {}

-- Callback used to get police count
lib.callback.register('sg-container:police', function()
    local policeCount = PlayersWithJob(config.PoliceJobNames)
    return policeCount or 0
  end)
  

local function getClosestContainer(coords)
    local closestContainerIndex
    for i = 1, #sharedConfig.containers do
        if #(coords - sharedConfig.containers[i].coords) <= 2 then
            if closestContainerIndex then
                if #(coords - sharedConfig.containers[i].coords) < #(coords - sharedConfig.containers[closestContainerIndex].coords) then
                    closestContainerIndex = i
                end
            else
                closestContainerIndex = i
            end
        end
    end
    return closestContainerIndex
end

RegisterNetEvent('sg-container:server:checkStatus', function()
    local coords = GetEntityCoords(GetPlayerPed(source))
    local closestContainerIndex = getClosestContainer(coords)
    local Player = GetPlayer(source)
    if not closestContainerIndex then return end

    if itemCount(Player, config.robberyitem, 1) then
        TriggerClientEvent('sg-container:client:initContainerAttempt', source, false)
    else
        Notify(Locals[sharedConfig.Language]['ItemRequiredLabel'], Locals[sharedConfig.Language]['ItemRequiredDesc'], 'error')
        return
    end

    startedContainer[source] = true
    sharedConfig.containers[closestContainerIndex].robbed = true
    TriggerClientEvent('sg-container:client:updatedRobbables', -1, sharedConfig.containers)
end)

RegisterNetEvent('sg-container:server:containerFailed', function()
    local coords = GetEntityCoords(GetPlayerPed(source))
    local closestContainerIndex = getClosestContainer(coords)
    local Player = GetPlayer(source)

    startedContainer[source] = false
    sharedConfig.containers[closestContainerIndex].robbed = false
    TriggerClientEvent('sg-container:client:updatedRobbables', -1, sharedConfig.containers)
    if config.removerobberyitemchange > math.random(0, 100) then
        Notify(Locals[sharedConfig.Language]['ItemBrokeLabel'], Locals[sharedConfig.Language]['ItemBrokeDesc'], 'error')
        RemoveItem(Player, 'crowbar', 1)
    end
end)


RegisterNetEvent('sg-container:server:containerCanceled', function()
    local coords = GetEntityCoords(GetPlayerPed(source))
    local closestContainerIndex = getClosestContainer(coords)
    startedContainer[source] = false
    
    sharedConfig.containers[closestContainerIndex].robbed = false
    TriggerClientEvent('sg-container:client:updatedRobbables', -1, sharedConfig.containers)
end)

RegisterNetEvent('sg-container:server:containerOpened', function(isDone)
    if not isDone then return end
    local Player = GetPlayer(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local closestContainerIndex = getClosestContainer(coords)


    local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
    local citizenid = Player.PlayerData.citizenid
  

    if not closestContainerIndex then return end
    if #(coords - sharedConfig.containers[closestContainerIndex].coords) > 2 then return end
    if not startedContainer[source] then return end

    if config.Itemloot then
    local chance = math.random(config.Itemchangemin, config.Itemchangemax)
    AddItem(Player, config.Loot, chance)

    logger.log({
        source = '',
        event = 'Container Robbery',
        color = 'green',
        message = '**Naam: **'.. firstname .. ' ' .. lastname .. ' \n ** Citizen ID: **' .. citizenid ..' \n **Inwoners ID: **'..source..' \n **Item: ** ' .. config.Loot .. '\n **Amount: ** '.. chance .. '',
        webhook = config.discordWebhook
     })

    end


    if config.Money then
        local chance = math.random(config.Moneyamountmin, config.Moneyamountmax)
        AddMoney(Player, 'cash', chance)
    
        logger.log({
            source = '',
            event = 'Container Robbery',
            color = 'green',
            message = '**Naam: **'.. firstname .. ' ' .. lastname .. ' \n ** Citizen ID: **' .. citizenid ..' \n **Inwoners ID: **'..source..' \n ** Money: ** Cash \n **Amount: ** '.. chance .. '',
            webhook = config.discordWebhook
         })
    
    end
    

    TriggerClientEvent('sg-container:client:updatedRobbables', -1, sharedConfig.containers)
    startedContainer[source] = false
    SetTimeout(config.containerRefresh, function()
        sharedConfig.containers[closestContainerIndex].robbed = false
        TriggerClientEvent('sg-container:client:updatedRobbables', -1, sharedConfig.containers)
    end)
end)


AddEventHandler('playerJoining', function(source)
    TriggerClientEvent('sg-container:client:updatedRobbables', source, sharedConfig.containers)
end)
