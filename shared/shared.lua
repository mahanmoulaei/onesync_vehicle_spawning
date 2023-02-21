Shared = {}

Shared.currentResourceName = GetCurrentResourceName()

Shared.generateHash = ("%s_%s"):format(Shared.currentResourceName, "generateHash")

Shared.hashTable = ("%s_%s"):format(Shared.currentResourceName, "hashTable")

Shared.spawnVehicleEvent = ("%s:%s"):format(Shared.currentResourceName, "spawnVehicleEvent")