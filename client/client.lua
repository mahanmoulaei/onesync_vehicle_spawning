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
    CreateThread(function()
        model = type(model) == "string" and joaat(model) or model
        local modelType = getVehicleType(model)
        local hash = lib.callback.await(Shared.generateHash, false)
        local hashTable = LocalPlayer.state[Shared.hashTable] or {}
        hashTable[hash] = hash
        LocalPlayer.state:set(Shared.hashTable, hashTable, true)
        TriggerServerEvent(Shared.spawnVehicleEvent, model, modelType, coords, properties, hash)
    end)
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
        -- print(model, coords)
        exports[Shared.currentResourceName]:spawnVehicle(model, coords)
    end
end)
]]