require "src/VectorOps"
require "src/Environment"
require "src/Color"
require "src/ObstacleAvoidance"

--[[
 Statemachine to move robots into a room.
--]]
MoveIntoRoom = {}

--[[
 Initializes the MoveIntoRoom state machine (singleton). The robot will go to
 the nearest room.
 
 Returns the room color.
--]]
function MoveIntoRoom.initNearest()
    local nearestDoor = getNearestDoor()
    local targetDoorColor = Color.new(nearestDoor.color)
    
    MoveIntoRoom.init(targetDoorColor)
    
    return targetDoorColor
end

--[[
 Initializes the MoveIntoRoom state machine (singleton).
--]]
function MoveIntoRoom.init(doorColor)
    -- Constants
    
    local STATES = {
        DOOR_ATTRACTION = 0,
        MOVE_INTO_ROOM = 1,
        INSIDE = 2
    }
    
    --[[
     Threshold (cm) used to move into a room and detect if the robot is inside
     the room or not.
    --]]
    local DOOR_THRESHOLD = 20
    
    -- Private attributes
    
    -- Current state
    local state = STATES.DOOR_ATTRACTION
    
    -- Door corresponding to the room to move into
    local targetDoorColor = doorColor
    
    -- public methods
    
    --[[
     Step function to move a robot to the specified room.
     1) attraction by door
     2) after threshold attained, move forward
     3) after a 2nd threshold is attained, we consider the robot is in the room
     
     Returns true once the robot is inside the room, else returns false.
    --]]
    function MoveIntoRoom.step()
        local targetDoor = getDoor(targetDoorColor)
        
        -- Obstacle detction if the target door is temporarily not visible by
        -- the camera.
        if (targetDoor == nil) then
            stepAvoid()
            return false
        end
        
        if (state == STATES.DOOR_ATTRACTION) then
            Bot.goTowardsAngle(targetDoor.angle)
            
            if (targetDoor.distance < DOOR_THRESHOLD) then
                state = STATES.MOVE_INTO_ROOM
            end
            
        elseif (state == STATES.MOVE_INTO_ROOM) then
            local nearestLightSource = getNearestElement(LIGHT_SOURCE_COLOR)
            nearestLightSource = nearestLightSource or { distance = 0, angle = 0}
            if (nearestLightSource.distance < 150) then
                nearestLightSource.value = nearestLightSource.distance * 100
            else
                nearestLightSource.value = 0
            end
            
            local nearestObject = getNearestElement(OBJECT_COLOR)
            nearestObject = nearestObject or { distance = 0, angle = 0}
            if (nearestObject.distance < 150) then
                nearestObject.value = nearestObject.distance * 100
            else
                nearestObject.value = 0
            end
            
            -- sum
            local finalVector = headTailSumPolarVectors({
                nearestLightSource, nearestObject
            })
            Bot.goTowardsAngle(finalVector.angle)
            
            if (targetDoor.distance > DOOR_THRESHOLD) then
                state = STATES.INSIDE
            end
            
        elseif (state == STATES.INSIDE) then
            return true
        end
        
        return false
    end
end
