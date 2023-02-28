local playerId = PlayerId()
local callbacks = {}
local vehicleTypes = {
    [8]  = "bike",
    [11] = "trailer",
    [13] = "bike",
    [14] = "boat",
    [15] = "heli",
    [16] = "plane",
    [21] = "train"
}

local function getVehicleType(model)
    return (model == `submersible` or model == `submersible2`) and "submarine" or vehicleTypes[GetVehicleClassFromName(model)] or "automobile"
end

local function spawnVehicle(model, coords, properties, cb)
    CreateThread(function()
        model = type(model) == "string" and joaat(model) or model
        local modelType = getVehicleType(model)
        local hash = lib.callback.await(Shared.generateHash, false)
        local hashTable = LocalPlayer.state[Shared.hashTable] or {}
        hashTable[hash] = hash
        LocalPlayer.state:set(Shared.hashTable, hashTable, true)
        if cb then callbacks[hash] = cb end
        TriggerServerEvent(Shared.spawnVehicleEvent, model, modelType, coords, properties, hash, cb and true)
    end)
end

lib.callback.register(Shared.getVehicleType, function(model)
    return getVehicleType(model)
end)

RegisterNetEvent(Shared.applyVehiclePropertiesEvent, function(vehicleNetId, vehicleProperties)
    if GetInvokingResource() then return end
    if not NetworkDoesEntityExistWithNetworkId(vehicleNetId) then return end
    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetId)
    -- local vehicleDriverPed = GetPedInVehicleSeat(vehicleEntity, -1)
    -- local isAnyOtherPlayerDriver = (vehicleDriverPed ~= 0 and vehicleDriverPed ~= PlayerPedId()) and true or false
    if NetworkGetEntityOwner(vehicleEntity) ~= playerId --[[or isAnyOtherPlayerDriver]] then return end
    lib.setVehicleProperties(vehicleEntity, vehicleProperties)
    TriggerServerEvent(Shared.appliedVehiclePropertiesEvent, vehicleNetId)
end)

RegisterNetEvent(Shared.vehicleSpawnedCallback, function(hash, vehicleNetId)
    if GetInvokingResource() then return end
    if hash and callbacks[hash] then
        local vehicleEntity = 0
        local attemptCount = 0
        local attempIncreaseAmount = 500
        while attemptCount < 5000 do
            if NetworkDoesEntityExistWithNetworkId(vehicleNetId) then
                vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetId)
                break
            end
            attemptCount += attempIncreaseAmount
            Wait(attempIncreaseAmount)
        end
        callbacks[hash](vehicleEntity, vehicleNetId)
    end
    callbacks[hash] = nil
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= Shared.currentResourceName then return end
    LocalPlayer.state:set(Shared.hashTable, nil, true)
end)

---@param model string
---@param coords? vector4
---@param properties? {}
---@param cb? function(vehicleEntity, vehicleNetId)
exports("spawnVehicle", function(model, coords, properties, cb)
    spawnVehicle(model, coords, properties, cb)
end)

RegisterCommand("spawn", function(source, args, rawMessage)
    if not args or not args[1] then return end
    exports[Shared.currentResourceName]:spawnVehicle(args[1], nil, {plate = " CLIENT"}, function(vehicleEntity, vehicleNetId)
        for i = 1, 20 do
            SetPedIntoVehicle(PlayerPedId(), vehicleEntity, -1)
            if GetVehiclePedIsIn(PlayerPedId(), false) == vehicleEntity then break end
        end
    end)
end, false)

--[[
-- test
CreateThread(function()
    Wait(5000)
    local vehicles = {
        ["lwgtr"] = vector4(119.35, -930.5, 29.8, 162.34),
        ["lwgtr2"] = vector4(116.96, -937.68, 29.72, 161.87),
        ["adder"] = vector4(112.98, -949.65, 29.59, 161.63),
        ["tenf"] = vector4(109.68, -958.95, 29.47, 161.02),
        ["tenf2"] = vector4(105.92, -971.01, 29.36, 163.7),
    }
    
    for model, coords in pairs(vehicles) do
        exports[Shared.currentResourceName]:spawnVehicle(model, coords, {plate = " CLIENT"})
    end
end)
]]