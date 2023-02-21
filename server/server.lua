local MAX_HASH_ID = 65535
local currentHashId = 0
local generatedHash = {}
local vehicleTypes = {}

local function generateHash()
    currentHashId = currentHashId < MAX_HASH_ID and currentHashId + 1 or 0
    local hash = ("%s%s"):format(currentHashId, os.clock())
    generatedHash[hash] = true
    return hash
end

local function spawnVehicle(model, modelType, coords, properties)
    local isCallFromServer = GetInvokingResource() and true or false
    local allPlayers = nil
    if isCallFromServer then allPlayers = GetPlayers() math.randomseed() end
    model = type(model) == "string" and joaat(model) or model
    modelType = modelType or vehicleTypes[model] or lib.callback.await(Shared.getVehicleType, allPlayers[math.random(#allPlayers)], model)

    local vehicle = CreateVehicleServerSetter(model, modelType, table.unpack(coords))
    local doesEntityExist = false
    local attemptCount = 0
    while attemptCount < 5000 do
        if DoesEntityExist(vehicle) then
            doesEntityExist = true
            break
        end
        attemptCount += 500
    end
    if not doesEntityExist then return print(("The vehicle(%s) did not spawn"):format(model)) end
end

lib.callback.register(Shared.generateHash, function(source)
    return source and generateHash()
end)

RegisterServerEvent(Shared.spawnVehicleEvent, function(model, modelType, coords, properties, hash)
    if not source then return end
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
    spawnVehicle(model, modelType, coords, properties)
end)

exports("spawnVehicle", function(model, coords, properties)
    if type(coords) ~= "vector4" then return end
    spawnVehicle(model, nil, coords, properties)
end)

RegisterCommand("spawn2", function(source, args, rawMessage)
    if not args or not args[1] then return end
    local playerPed = GetPlayerPed(source)
    ---@diagnostic disable-next-line: param-type-mismatch
    exports[Shared.currentResourceName]:spawnVehicle(args[1], vector4(GetEntityCoords(playerPed), GetEntityHeading(playerPed)))
end, false)