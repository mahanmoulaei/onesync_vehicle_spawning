local maxHashId = 65535
local currentHashId = 0
local generatedHash = {}
local vehicleTypes = {}

local function generateHash()
    currentHashId = currentHashId < maxHashId and currentHashId + 1 or 0
    local hash = tonumber(("%s%s"):format(currentHashId, os.clock()))
    generatedHash[hash] = true
    return hash
end

CreateThread(function()
    GlobalState:set(Shared.generateHash, generateHash, true)
end)

RegisterServerEvent(Shared.spawnVehicleEvent, function(model, modelType, coords, properties, hash)
    if not source then return end
    local doesHashMatch = generatedHash[Player(source).state[Shared.hashTable]?[hash]] and true or false
    generatedHash[hash] = nil
    Player(source).state[Shared.hashTable][hash] = nil
    if not doesHashMatch then return print(("NOT doesHashMatch => Player[%s] = %s is most probably cheating!"):format(source, GetPlayerName(source))) end
    if not model or not modelType then return end
    local playerPed = GetPlayerPed(source)
    coords = coords and vector4(coords.x, coords.y, coords.z, coords.w or GetEntityHeading(playerPed)) or vector4(table.unpack(GetEntityCoords(playerPed)), GetEntityHeading(playerPed))
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