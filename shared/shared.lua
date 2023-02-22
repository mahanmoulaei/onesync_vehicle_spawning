Shared = {}

Shared.currentResourceName = GetCurrentResourceName()

Shared.hashTable = ("%s_%s"):format(Shared.currentResourceName, "hashTable")

Shared.generateHash = ("%s:%s"):format(Shared.currentResourceName, "generateHash")

Shared.getVehicleType = ("%s:%s"):format(Shared.currentResourceName, "getVehicleType")

Shared.spawnVehicleEvent = ("%s:%s"):format(Shared.currentResourceName, "spawnVehicleEvent")

Shared.applyVehiclePropertiesEvent = ("%s:%s"):format(Shared.currentResourceName, "applyVehiclePropertiesEvent")

Shared.appliedVehiclePropertiesEvent = ("%s:%s"):format(Shared.currentResourceName, "appliedVehiclePropertiesEvent")

function dumpTable(table, nb)
    if nb == nil then
        nb = 0
    end

    if type(table) == 'table' then
        local s = ''
        for i = 1, nb + 1, 1 do
            s = s .. "    "
        end

        s = '{\n'
        for k,v in pairs(table) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            for i = 1, nb, 1 do
                s = s .. "    "
            end
            s = s .. '['..k..'] = ' .. dumpTable(v, nb + 1) .. ',\n'
        end

        for i = 1, nb, 1 do
            s = s .. "    "
        end

        return s .. '}'
    else
        return tostring(table)
    end
end