RegisterCommand(config.commands.revive, function(source, args, raw)
    local to_rev = source

    if args[1] ~= nil then
        local player_id = tonumber(args[1])

        if player_id == nil or player_id == 0 or GetPlayerName(player_id) == nil then
            TriggerClientEvent('chatMessage', source, 'Alex\'s Medical Services', {
                200,
                0,
                0
            },
                'That Player ID is either invalid or the player have gone offline')
        end

        if to_rev == player_id then
            TriggerClientEvent('chatMessage', source, 'Alex\' Medical Services', {
                200,
                0,
                0
            },
                'A player ID isn\'t needed when reviving yourself. Just do /' .. config.commands.revive)
        end

        to_rev = player_id
    end

    local name = 'yourself'

    if source ~= to_rev then
        name = GetPlayerName(to_rev)
        TriggerClientEvent('alexs-rpdeath:revive', to_rev, GetPlayerName(source))
    else
        TriggerClientEvent('alexs-rpdeath:revive', to_rev)
    end

    if config.webhook ~= nil then
        if name == 'yourself' then
            TriggerEvent('alexs-discordwebhook:dispatch', {
                name = nil,
                icon = nil,
                from = source,
                discord_message = 'Revived themselves',
                web_hook = config.webhook
            })
        else
            TriggerEvent('alexs-discordwebhook:dispatch', {
                name = nil,
                icon = nil,
                from = source,
                discord_message = 'Revived ' .. name,
                web_hook = config.webhook
            })
        end
    end

    TriggerClientEvent('chatMessage', source, 'Alex\s Medical Services', {
        200,
        0,
        0
    },
        'Reviving ' .. name)
end, config.commands.revive_requires_ace or false)