AddCSLuaFile("lua/entities/consoleent/cl_init.lua")
AddCSLuaFile("entities/consoleent/shared.lua")

include("entities/consoleent/shared.lua")
include("autorun/server/sv_config.lua")

function ENT:Initialize()

    self:SetModel(returnEntityModel())
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)
        local concatValue = #ents.FindByClass("consoleent") -- Find the number of spawned consoles
    self:SetName("DevonsConsoleEntity" .. concatValue) -- Sets a unique name

end

-- Checks to see if the player has spawned a console
util.AddNetworkString("PlayerSpawnedConsole")
hook.Add("PlayerSpawnedSENT", "checkForConsole", function(ply, ent)

    if(string.find(ent:GetName(), "DevonsConsoleEntity")) then -- If the entity is the console
        net.Start("PlayerSpawnedConsole")
            net.WriteEntity(ply) -- Send the player who spawned it to the server
            net.WriteString(ent:GetName())
        net.Send(ply)
    end

end)

playersInConsole = {}

function ENT:AcceptInput(name, activator, caller) -- Sets up interactions for the console       

local canAccess = nil
local information = nil

    if(name == "Use") then -- If the entity is "used"
        if(activator:GetActiveWeapon():GetClass() == "weapon_hacking") then
            for k, v in pairs(returnSpawnedEntities()) do -- Loop through the table of spawned entities
                if(v.entityName == self:GetName()) then -- If the entity name is equal to a table name
                    information = v.information
                    canAccess = true
                end
            end
            if(canAccess == true) then
                util.AddNetworkString("ServerSendsEntityInformation")
                net.Start("ServerSendsEntityInformation") -- Start a network string
                    net.WriteEntity(self) -- Sends the console info
                    net.WriteEntity(activator) -- Sends the player info
                    net.WriteTable(information) -- Send all the console information in a table
                    net.WriteString(self:GetName())
                net.Send(activator)

            table.insert(playersInConsole, table.maxn(playersInConsole), activator:SteamID64())   
            end
        else
            activator:ChatPrint("You don't have the necessary tools to hack this console.")
        end   
    end
end

util.AddNetworkString("updateInUse")
net.Receive("updateInUse", function()
    updateInUse(net.ReadString(), true)
end)

util.AddNetworkString("PlayerDied")
hook.Add("PlayerDeath", "checkForInConsole", function(victim)
    if table.HasValue(playersInConsole, victim:SteamID64()) then
        net.Start("PlayerDied")
        net.Send(victim)
        table.remove(playersInConsole, victim:SteamID64())
    end
end)

util.AddNetworkString("playerQuitConsole")
net.Receive("playerQuitConsole", function()

    table.remove(playersInConsole, net.ReadEntity():SteamID64())
    updateInUse(net.ReadEntity():GetName(), false)

end)

doorStillLocked = nil

util.AddNetworkString("ServerWaitingForEntity")
util.AddNetworkString("PlayerAlert")
net.Receive("ServerWaitingForEntity", function()

    local callingPlayer = net.ReadEntity()
    doorStillLocked = true

    hook.Add("PlayerSay", "doesThePlayerSetAnEntity", function(ply, text)
        if(text == "!setEntity" and ply:SteamID64() == callingPlayer:SteamID64()) then
            if(ply:GetEyeTrace().Entity:GetClass() == "func_door") then
                lockedDoor = ply:GetEyeTrace().Entity:GetCreationID()
                actualEntity = ply:GetEyeTrace().Entity
                actualEntity:Fire("Lock")
                ply:ChatPrint("Entity successfully set")
            else 
                ply:ChatPrint("That is not a valid door object.")
            end
        end
    end)
    hook.Add("PlayerUse", "isUsingOurObject", function(ply2, ent)
        if(doorStillLocked) then
            if(lockedDoor == ply2:GetEyeTrace().Entity:GetCreationID()) then
                net.Start("PlayerAlert")
                net.Send(ply2)
                return false
            else
                return true
            end  
        end
        
    end)

end)

util.AddNetworkString("PlayerActivatedDoor")
net.Receive("PlayerActivatedDoor", function()
    doorStillLocked = false
    actualEntity:Fire("Unlock")

    net.ReadEntity():Remove()
end)

util.AddNetworkString("destroyOnServer")
net.Receive("destroyOnServer", function()
    net.ReadEntity():Remove()
end)