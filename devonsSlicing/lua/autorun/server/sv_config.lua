AddCSLuaFile("entities/consoleent/shared.lua")
AddCSLuaFile("entities/consoleent/cl_init.lua")
AddCSLuaFile("weapons/weapon_hacking.lua")









entityModel = "models/props_combine/combine_interface001.mdl" -- This is the model you want for the console













--[[
WARNING - DO NOT EDIT BELOW HERE
--]]

function returnEntityModel()
    if (entityModel != nil) then
        return entityModel
    end
    if(entityModel == nil) then
        return "models/props_combine/combine_interface001.mdl"
    end
end

spawnedEntities = {} -- Empty table to write info to

util.AddNetworkString("AdminFinishedCreation")
net.Receive("AdminFinishedCreation", function()

    givenInformation = net.ReadTable()
    --[[
    Output of this table is
    [1] = name
    [2] = delay
    [3] = fileType
    [4] = fileName
    [5] = entityName
    --]]

    local insertTable = {
        entityName = givenInformation[5],
        information = {
            name = string.lower(givenInformation[1]),
            delay = givenInformation[2],
            fileType = givenInformation[3],
            fileName = string.lower(givenInformation[4]),
            inUse = false,
        },
    }

    table.insert(spawnedEntities, table.maxn(spawnedEntities) + 1, insertTable) -- Inserts the entity information into a list of others

end)

function returnSpawnedEntities()
    if(spawnedEntities != nil) then
        return spawnedEntities
    end
end

function updateInUse(consoleName, setValue)
    for k, v in pairs(spawnedEntities) do
        if v.entityName == consoleName then
            if(setValue != nil) then
                v.information["inUse"] = setValue
            else
                v.information["inUse"] = !v.information["inUse"]
            end
        end
    end
end