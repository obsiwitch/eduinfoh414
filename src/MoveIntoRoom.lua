require "src/Movement"
require "src/RoomDetection"
require "src/Color"

--[[
 Statemachine to move robots into a room.
--]]

--[[
 Threshold (cm) used to move into a room and detect if the robot is inside the room
 or not.
--]]
local DOOR_THRESHOLD = 30

local STATES = {
    DOOR_ATTRACTION = 0,
    MOVE_INTO_ROOM = 1,
    INSIDE = 2
}

-- Current state
local state

-- Door corresponding to the room to move into
local targetDoorColor

--[[
 Initializes the state machine.
--]]
function initMoveIntoRoom(doorColor)
    state = STATES.DOOR_ATTRACTION
    targetDoorColor = doorColor
end

--[[
 Initializes the state machine. The room the robot will go into correspond to
 the nearest door.
 
 Returns the room color.
--]]
function initMoveIntoNearestRoom()
    local nearestDoor = getNearestDoor()
    
    targetDoorColor = Color.new(nearestDoor.color)
    
    state = STATES.DOOR_ATTRACTION
    
    return targetDoorColor
end

--[[
 Step function to move a robot to the specified room.
 1) attraction by door
 2) after threshold attained, move forward
 3) after a 2nd threshold is attained, we consider the robot is in the room
 
 Returns true once the robot is inside the room, else returns false.
--]]
function stepMoveIntoRoom()
    local targetDoor = getDoor(targetDoorColor)
    
    if (state == STATES.DOOR_ATTRACTION) then
        local speeds = computeSpeedsFromAngle(targetDoor.angle)
        robot.wheels.set_velocity(speeds[1], speeds[2])
        
        if (targetDoor.distance < DOOR_THRESHOLD) then
            state = STATES.MOVE_INTO_ROOM
        end
        
    elseif (state == STATES.MOVE_INTO_ROOM) then
        robot.wheels.set_velocity(WHEEL_SPEED, WHEEL_SPEED)
        
        if (targetDoor.distance > DOOR_THRESHOLD) then
            state = STATES.INSIDE
        end
        
    elseif (state == STATES.INSIDE) then
        return true
    end
    
    return false
end
