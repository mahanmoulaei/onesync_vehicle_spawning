local MAX_HASH_ID = 65535
local currentHashId = 0
local generatedHash = {}
local vehicleTypes = {}
local vehiclesProperties = {}
local isVehiclePropertiesThreadRunning = false

local function generateHash()
    currentHashId = currentHashId < MAX_HASH_ID and currentHashId + 1 or 0
    local hash = ("%s%s"):format(currentHashId, os.clock())
    generatedHash[hash] = true
    return hash
end

lib.callback.register(Shared.generateHash, function(source)
    return source and generateHash()
end)

local function applyVehicleProperties(vehicle, properties)
    vehiclesProperties[vehicle] = properties
    if isVehiclePropertiesThreadRunning then return end
    isVehiclePropertiesThreadRunning = true
    CreateThread(function()
        while isVehiclePropertiesThreadRunning do
            local vehiclesPropertiesCount = 0
            for vehicleEntity, vehicleProperties in pairs(vehiclesProperties) do
                vehiclesPropertiesCount += 1
                if not DoesEntityExist(vehicleEntity) then vehiclesProperties[vehicleEntity] = nil vehiclesPropertiesCount -= 1 goto skipIndex end
                local currentOwner = NetworkGetEntityOwner(vehicleEntity)
                if not currentOwner or currentOwner == 0 or currentOwner == -1 then goto skipIndex end
                TriggerClientEvent(Shared.applyVehiclePropertiesEvent, currentOwner, NetworkGetNetworkIdFromEntity(vehicleEntity), vehicleProperties)
                ::skipIndex::
            end
            if vehiclesPropertiesCount == 0 then isVehiclePropertiesThreadRunning = false break end
            Wait(500)
        end
    end)
end

local function spawnVehicle(model, modelType, coords, properties, cb)
    CreateThread(function()
        local allPlayers = GetPlayers() math.randomseed()
        model = type(model) == "string" and joaat(model) or model
        modelType = modelType or vehicleTypes[model] or lib.callback.await(Shared.getVehicleType, allPlayers[math.random(#allPlayers)], model)
        vehicleTypes[model] = modelType

        local vehicle = CreateVehicleServerSetter(model, modelType, table.unpack(coords))
        local doesEntityExist = false
        local attemptCount = 0
        local attempIncreaseAmount = 500
        while attemptCount < 5000 do
            if DoesEntityExist(vehicle) then
                doesEntityExist = true
                break
            end
            attemptCount += attempIncreaseAmount
            Wait(attempIncreaseAmount)
        end
        if not doesEntityExist then return print(("The vehicle(%s) did not spawn"):format(model)) end
        if properties then applyVehicleProperties(vehicle, properties) end
        if cb then cb(vehicle, NetworkGetNetworkIdFromEntity(vehicle)) end
    end)
end

RegisterServerEvent(Shared.spawnVehicleEvent, function(model, modelType, coords, properties, hash, cb)
    if not source then return end
    local source = source
    local hashTable = Player(source).state[Shared.hashTable] or {}
    local doesHashMatch = generatedHash[hashTable[hash]] and true or false
    generatedHash[hash] = nil
    hashTable[hash] = nil
    Player(source).state:set(Shared.hashTable, hashTable, true)
    if not doesHashMatch then return print(("NOT doesHashMatch => Player[%s] = %s is most probably cheating!"):format(source, GetPlayerName(source))) end
    if not model or not modelType then return end
    local playerPed = GetPlayerPed(source)
    ---@diagnostic disable-next-line: param-type-mismatch
    coords = coords and vector4(coords.x, coords.y, coords.z, coords.w or GetEntityHeading(playerPed)) or vector4(GetEntityCoords(playerPed), GetEntityHeading(playerPed))
    spawnVehicle(model, modelType, coords, properties, cb and function(vehicleEntity, vehicleNetId)
        TriggerClientEvent(Shared.vehicleSpawnedCallback, source, cb, vehicleNetId)
    end)
end)

RegisterServerEvent(Shared.appliedVehiclePropertiesEvent, function(vehicleNetId)
    vehiclesProperties[NetworkGetEntityFromNetworkId(vehicleNetId)] = nil
end)

---@param model string
---@param coords vector4
---@param properties? {}
---@param cb? function(vehicleEntity, vehicleNetId)
exports("spawnVehicle", function(model, coords, properties, cb)
    if not coords or type(coords) ~= "vector4" then return end
    spawnVehicle(model, nil, coords, properties, cb)
end)

RegisterCommand("spawn2", function(source, args, rawMessage)
    if not args or not args[1] then return end
    local playerPed = GetPlayerPed(source)
    ---@diagnostic disable-next-line: param-type-mismatch
    exports[Shared.currentResourceName]:spawnVehicle(args[1], vector4(GetEntityCoords(playerPed), GetEntityHeading(playerPed)), {plate = " SERVER"}, function(vehicleEntity, vehicleNetId)
        for i = 1, 20 do
            SetPedIntoVehicle(playerPed, vehicleEntity, -1)
            if GetVehiclePedIsIn(playerPed, false) == vehicleEntity then
                break
            end
            Wait(0)
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
        exports[Shared.currentResourceName]:spawnVehicle(model, coords, {plate = " SERVER"})
    end
end)
]]