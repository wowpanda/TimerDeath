local isDead = false
local time_of_death = nil
local first_spawn = true
local respawn_timer = config.respawn_timer * 1000 * 60

function respawn(location)
    isDead = false
    local coords = nil
    local player_ped = GetPlayerPed(-1)

    if location == 'sandy' then
        coords = config.hospitals.sandy
    elseif location == 'los_santos' then
        coords = config.hospitals.los_santos
    end

    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end

    SetEntityCoordsNoOffset(player_ped, coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
    SetPlayerInvincible(player_ped, false)
    TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
    ClearPedBloodDamage(player_ped)

    StopScreenEffect('DeathFailOut')
    DoScreenFadeIn(800)

    TriggerEvent('chatMessage', 'Alex\'s Medical Services', {
        200,
        0,
        0
    },
        'You have been picked up by EMS! Remember the new life rules!')
end

function revive()
    StopScreenEffect('DeathFailOut')
    DoScreenFadeIn(800)
    isDead = false
    local player_ped = GetPlayerPed(-1)
    local player_pos = GetEntityCoords(player_ped, true)

    NetworkResurrectLocalPlayer(player_pos, true, true, false)
    SetPlayerInvincible(player_ped, false)
    ClearPedBloodDamage(player_ped)
    TriggerEvent('playerSpawned', player_pos.x, player_pos.y, player_pos.z, player_pos.heading)
end

function onDeath()
    isDead = true
    time_of_death = GetGameTimer()
    local player_ped = GetPlayerPed(-1)
    SetPlayerInvincible(player_ped, true)
    SetEntityHealth(player_ped, 1)
    ClearPedTasksImmediately(player_ped)
    StartScreenEffect('DeathFailOut', 0, false)
end

function drawDeathTimer(text)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.8)
end

function showRespawn()
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.45, 0.45)
    SetTextColour(185, 185, 185, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName('Press [~b~L~s~] to respawn in LS')
    EndTextCommandDisplayText(0.175, 0.805)

    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.45, 0.45)
    SetTextColour(185, 185, 185, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName('Press [~b~S~s~] to respawn in Sandy')
    EndTextCommandDisplayText(0.175, 0.835)
end

AddEventHandler('playerSpawned', function()
    isDead = false

    if first_spawn then
        first_spawn = false

        exports.spawnmanager:setAutoSpawn(false)
    end
end)

RegisterNetEvent('alexs-rpdeath:revive')
AddEventHandler('alexs-rpdeath:revive', function(by)
    revive()
    if by ~= nil then
        TriggerEvent('chatMessage', 'Alex\'s Medical Services', {
            200,
            0,
            0
        },
            by .. ' have revived you!')
    end
end)

AddEventHandler('alexs-rpdeath:respawn', function(location)
    respawn(location)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local player_ped = GetPlayerPed(-1)

        if IsEntityDead(player_ped) and isDead == false then
            onDeath()
        end

        if isDead then
            if time_of_death ~= nil then
                local current_time = GetGameTimer()
                local wait_period = time_of_death + respawn_timer

                if current_time < wait_period then
                    local secs = math.ceil((wait_period - current_time) / 1000)
                    local minutes = 0
                    local seconds = 0
                    local message = ""

                    while secs >= 60 do
                        secs = secs - 60;
                        minutes = minutes + 1
                    end

                    seconds = secs

                    if minutes > 0 then
                        message = "~b~" .. minutes .. ' minute'

                        if minutes > 1 then
                            message = message .. 's'
                        end

                        message = message .. '~s~'
                    end

                    if seconds > 0 then
                        if message ~= "" then
                            message = message .. " and "
                        end

                        message = message .. "~b~" .. seconds .. " second"

                        if seconds > 1 then
                            message = message .. 's'
                        end

                        message = message .. '~s~'
                    end

                    message = "You may respawn in " .. message .. " IF EMS is unavailable."
                    drawDeathTimer(message)
                else
                    drawDeathTimer("You may respawn now ~b~IF~s~ you've made a 911 call and EMS is unavailable")
                    showRespawn()

                    -- L
                    if IsControlPressed(0, 182) then
                        TriggerEvent('alexs-rpdeath:respawn', 'los_santos')
                    end

                    -- S
                    if IsControlPressed(0, 8) then
                        TriggerEvent('alexs-rpdeath:respawn', 'sandy')
                    end
                end
            end
        end
    end
end)