# This is a snippet for server-side vehicle spawning in FiveM OneSync

* It is more optimized than most methods out there [so far]
* Applies vehicle properties in a better & more optimized way(it doesn't use state bags change handlers, so not all clients will be invoked)
* Both client-side and server-side exports, spawn the vehicles server-sided
* Important events are sensitive to exploit and are secured

<hr>

## Client Export
```lua
---@param vehicleModel string
---@param vehicleCoords? vector4 - optional
---@param vehicleProperties? {} - optional
---@param cb? function(vehicleEntity, vehicleNetId) - optional
exports["onesync_vehicle_spawning"]:spawnVehicle(vehicleModel, vehicleCoords, vehicleProperties, cb)
```

## Server Export
```lua
---@param vehicleModel string
---@param vehicleCoords vector4
---@param vehicleProperties? {} - optional
---@param cb? function(vehicleEntity, vehicleNetId) - optional
exports["onesync_vehicle_spawning"]:spawnVehicle(vehicleModel, vehicleCoords, vehicleProperties, cb)
```

<hr>

P.S. Note that this resource is just a SNIPPET
