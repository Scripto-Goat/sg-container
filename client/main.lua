local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function checkInteractStatus(container)
    if sharedConfig.containers[container].robbed then
        return false
    end

    local policeCount = lib.callback.await('sg-container:police', false)
    if policeCount >= sharedConfig.minimumCops then
        return true
    end

    return false
end

local function alertPolice()
    local hours = GetClockHours()
    local chance = config.policeAlertChance
    if hours >= 1 and hours <= 6 then
        chance = config.policeNightAlertChance
    end

    if math.random() <= chance then
        -- Place here dispatch export
        print('Dispatch')
    end
end

local function openContainerAnim()
    lib.requestAnimDict('missheistfbi3b_ig7', 100)
    TaskPlayAnim(cache.ped, 'missheistfbi3b_ig7', 'lift_fibagent_loop', 5.0, 1.0, 1200, 1, 0, false, false, false)
    RemoveAnimDict('missheistfbi3b_ig7')
end



RegisterNetEvent('sg-container:client:initContainerAttempt', function()
                alertPolice()
                openContainerAnim()
                local success = lib.skillCheck({'easy', 'easy'}, {'e', 'e'})
                if not success then 
                    TriggerServerEvent('sg-container:server:containerFailed')
                    return
                end
                
                if lib.progressBar({
                    duration = config.openContainerTime,
                    label = Locals[sharedConfig.Language]['ContainerEmptyingLabel'],
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        car = true,
                        mouse = false,
                        combat = true
                    },
                    anim = {
                        dict = 'missheist_agency3aig_23',
                        clip = 'urinal_sink_loop',
                        blendIn = 1.0,
                        duration = config.openContainerTime,
                        blendOut = 1.0,
                    },
                }) then -- if completed
                    TriggerServerEvent('sg-container:server:containerOpened', true)
                else -- if canceled
                    TriggerServerEvent('sg-container:server:containerCanceled')
                    Notify(Locals[sharedConfig.Language]['ContainerLabel'], Locals[sharedConfig.Language]['ContainerDesc'], 'error')
                end
    
end)

RegisterNetEvent('sg-container:client:updatedRobbables', function(container)
    sharedConfig.containers = container
end)


local function createContainers()
    CreateThread(function()
        for i=1, #sharedConfig.containers do
            exports.ox_target:addSphereZone({
                coords = sharedConfig.containers[i].coords,
                radius = 0.8,
                debug = config.debugPoly,
                options = {
                    {
                        name = i..'_container',
                        icon = 'fas fa-user-secret',
                        iconColor = '#D0EBFE',
                        label = 'Breakin',
                        canInteract = function()
                            return checkInteractStatus(i)
                        end,
                        serverEvent = 'sg-container:server:checkStatus',
                        distance = 1,
                    }
                }
            })
        end
    end)
end

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= cache.resource then return end
    createContainers()
end)
