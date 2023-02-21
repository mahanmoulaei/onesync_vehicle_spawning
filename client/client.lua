local vehicleTypes = {
    [8]  = "bike",
    [11] = "trailer",
    [13] = "bike",
    [14] = "boat",
    [15] = "heli",
    [16] = "plane",
    [21] = "train"
}

local function spawnVehicle(model, coords, properties)
    model = type(model) == "string" and joaat(model) or model
    local modelType = (model == `submersible` or model == `submersible2`) and "submarine" or vehicleTypes[GetVehicleClassFromName(model)] or "automobile"
    local hash = lib.callback.await(Shared.generateHash, false)
    local hashTable = LocalPlayer.state[Shared.hashTable] or {}
    hashTable[hash] = hash
    LocalPlayer.state:set(Shared.hashTable, hashTable, true)
    TriggerServerEvent(Shared.spawnVehicleEvent, model, modelType, coords, properties, hash)
end

RegisterCommand("spawn", function(source, args, rawMessage)
    if not args or not args[1] then return end
    spawnVehicle(args[1])
end, false)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= Shared.currentResourceName then return end
    LocalPlayer.state:set(Shared.hashTable, nil, true)
end)