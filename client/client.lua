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

local function spawnVehicle(model, coords, properties)
    model = type(model) == "string" and joaat(model) or model
    local modelType = getVehicleType(model)
    local hash = lib.callback.await(Shared.generateHash, false)
    local hashTable = LocalPlayer.state[Shared.hashTable] or {}
    hashTable[hash] = hash
    LocalPlayer.state:set(Shared.hashTable, hashTable, true)
    TriggerServerEvent(Shared.spawnVehicleEvent, model, modelType, coords, properties, hash)
end

lib.callback.register(Shared.getVehicleType, function(model)
    return getVehicleType(model)
end)

exports("spawnVehicle", spawnVehicle)

RegisterCommand("spawn", function(source, args, rawMessage)
    if not args or not args[1] then return end
    exports[Shared.currentResourceName]:spawnVehicle(args[1])
end, false)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= Shared.currentResourceName then return end
    LocalPlayer.state:set(Shared.hashTable, nil, true)
end)