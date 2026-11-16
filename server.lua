local function notify(source, message, kind)
    exports.whip_core:NotifyPlayer(source, message, kind or 'info')
end

RegisterCommand('car', function(source, args)
    if source == 0 then
        print('[whip_car_command] This command must be used in-game.')
        return
    end

    if not IsPlayerAceAllowed(source, 'command.car') then
        notify(source, 'You do not have permission to use /car.', 'error')
        return
    end

    local model = args[1]
    if not model or model == '' then
        notify(source, 'Usage: /car [vehicle model]', 'info')
        return
    end

    model = string.lower(model)
    if #model > 64 or not model:match('^[%w_%-]+$') then
        notify(source, 'That vehicle model name is not valid.', 'error')
        return
    end

    local exists = exports.whip_core:VehicleModelExists(model)
    if exists == false then
        notify(source, ('No vehicle named "%s" was found.'):format(model), 'error')
        return
    end

    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then
        notify(source, 'Your character could not be found.', 'error')
        return
    end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local spawnCoords = vector4(coords.x, coords.y, coords.z, heading)

    local vehicleId, reason = exports.whip_core:SpawnTempVehicle(model, spawnCoords, {
        forSource = source,
        giveKey = true,
        idleDespawn = false,
        locked = false,
    })

    if not vehicleId then
        notify(source, reason or 'The vehicle could not be spawned.', 'error')
        return
    end

    local vehicle = exports.whip_core:GetVehicle(vehicleId)
    if vehicle and vehicle.netId then
        TriggerClientEvent('whip_car_command:seatPlayer', source, vehicle.netId)
    end

    notify(source, ('Spawned %s.'):format(model), 'success')
end, false)

RegisterCommand('dv', function(source)
    if source == 0 then
        print('[whip_car_command] This command must be used in-game.')
        return
    end

    if not IsPlayerAceAllowed(source, 'command.dv') then
        notify(source, 'You do not have permission to use /dv.', 'error')
        return
    end

    TriggerClientEvent('whip_car_command:findVehicleToDelete', source)
end, false)

RegisterNetEvent('whip_car_command:deleteResult', function(netId)
    local src = source
    if not IsPlayerAceAllowed(src, 'command.dv') then
        notify(src, 'You do not have permission to use /dv.', 'error')
        return
    end

    if type(netId) ~= 'number' or netId <= 0 then
        notify(src, 'No vehicle found nearby.', 'error')
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then
        notify(src, 'That vehicle could not be found.', 'error')
        return
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local playerCoords = GetEntityCoords(ped)
    local vehicleCoords = GetEntityCoords(vehicle)
    local dx = playerCoords.x - vehicleCoords.x
    local dy = playerCoords.y - vehicleCoords.y
    local dz = playerCoords.z - vehicleCoords.z
    if (dx * dx + dy * dy + dz * dz) > 64.0 then
        notify(src, 'The vehicle is too far away.', 'error')
        return
    end

    DeleteEntity(vehicle)
    notify(src, 'Vehicle deleted.', 'success')
end)
