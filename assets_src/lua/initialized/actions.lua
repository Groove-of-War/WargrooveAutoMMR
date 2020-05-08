local Events = require "initialized/events"
local Wargroove = require "wargroove/wargroove"

local Actions = {}

function Actions.init()
  Events.addToActionsList(Actions)
end

function Actions.populate(dst)
    dst["aw_fire_spawn"] = Actions.spawnFire
    dst["aw_fire_vision"] = Actions.awFireVision
end

function Actions.awFireVision(context)

    local playerId = Wargroove.getCurrentPlayerId()
    local units = Wargroove.getUnitsAtLocation(nil)
    for i, unit in ipairs(units) do
        if unit.unitClass.id == "aw_fire" then
            unit.playerId = playerId
            Wargroove.updateUnit(unit)
        end
    end
    Wargroove.updateFogOfWar(nil)
    
end

function Actions.spawnFire(context)

    local playerId = 0
    for i, unit in ipairs(Wargroove.getUnitsAtLocation(nil)) do
        if unit.unitClass.id == "villager" then
            local pos = unit.pos
            Wargroove.removeUnit(unit.id)
            Wargroove.waitFrame()
            if Wargroove.canStandAt("aw_fire", pos) then
                Wargroove.spawnUnit(playerId, pos, "aw_fire", false)
                Wargroove.waitFrame()
            end
        end
    end
    Wargroove.updateFogOfWar(nil)
end

return Actions
