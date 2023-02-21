local maxHashId = 65535
local currentHashId = 0
local generatedHash = {}

local function generateHash()
    currentHashId = currentHashId < maxHashId and currentHashId + 1 or 0
    local hash = ("%s%s"):format(currentHashId, os.clock())
    generatedHash[hash] = true
    return hash
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
end)