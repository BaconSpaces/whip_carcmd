RegisterNetEvent('whip_car_command:seatPlayer', function(netId)
    if type(netId) ~= 'number' then return end

    local timeout = GetGameTimer() + 10000
    local vehicle = 0

    while GetGameTimer() < timeout do
        if NetworkDoesEntityExistWithNetworkId(netId) then
            vehicle = NetToVeh(netId)
            if vehicle ~= 0 and DoesEntityExist(vehicle) then
                break
            end
        end
        Wait(100)
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        SetPedIntoVehicle(ped, vehicle, -1)
    end
end)

RegisterNetEvent('whip_car_command:findVehicleToDelete', function()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        vehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 70)
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        TriggerServerEvent('whip_car_command:deleteResult', 0)
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId == 0 then
        TriggerServerEvent('whip_car_command:deleteResult', 0)
        return
    end

    TriggerServerEvent('whip_car_command:deleteResult', netId)
end)

