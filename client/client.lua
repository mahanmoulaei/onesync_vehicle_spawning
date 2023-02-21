local vehicleTypes = {
    [8] = "bike",
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
    local hashTable = LocalPlayer.state[Shared.hashTable] or {}
    local hash = GlobalState[Shared.generateHash]()
    hashTable[hash] = hash
    LocalPlayer.state:set(Shared.hashTable, hashTable, true)
    TriggerServerEvent(Shared.spawnVehicleEvent, model, modelType, coords, properties, hash)
end