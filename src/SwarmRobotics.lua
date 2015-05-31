-- TODO clean requires
require "src/RobotType"
require "src/RoomDetection"
require "src/MoveIntoRoom"
require "src/TargetRoomFormation"
require "src/EvaluateRoom"
require "src/Gather"

--[[
 Table listing the different states a robot can enter.
 * START
 * INIT_SPLIT_ROOMS: initializes the MoveIntoRoom state machine with the nearest
 room
 * SPLIT_ROOMS: move into the nearest room
 * ROOM_FORMATION: group robots inside rooms between the light source and the
 door, and evaluate the room
 * GATHER: gather robots that have already evaluated their room, and share
 their score
--]]
local STATES = {
    START = 0,
    INIT_SPLIT_ROOMS = 1,
    SPLIT_ROOMS = 2,
    ROOM_FORMATION = 3,
    GATHER = 4
}

-- Current state
local state

--[[
 Current robot's type (G or L)
--]]
local robotType

--[[
 Color of the room associated with this robot.
--]]
local roomColor

--[[
 Enables the camera and initialize variables (i.e. state, robotType).
--]]
function init()
    robot.colored_blob_omnidirectional_camera.enable()
    
    state = STATES.START
    
    robotType = getRobotType()
    setRobotColor(robotType)
end

--[[
 State machine executed at each time step.
 @see STATES
--]]
function step()
    if (state == STATES.START) then
        -- Wait one time step before starting. This is done in order to avoid a
        -- problem with the camera (returned distances during the first time
        -- step are not correct).
        state = STATES.INIT_SPLIT_ROOMS
        
    elseif (state == STATES.INIT_SPLIT_ROOMS) then
        roomColor = MoveIntoRoom.initNearest()
        state = STATES.SPLIT_ROOMS
        
    elseif (state == STATES.SPLIT_ROOMS) then
        local isInsideRoom = MoveIntoRoom.step()
        
        -- Share position to robots already in state ROOM_FORMATION in order to
        -- repulse them, and thus avoid being blocked in front of doors.
        robot.range_and_bearing.set_data(I_BYTE_PING, 1)

        if isInsideRoom then
            initEvaluate()
            state = STATES.ROOM_FORMATION
        end
    
    elseif (state == STATES.ROOM_FORMATION) then
        stepTargetRoomFormation(robotType)
        local evalStatus = stepEvaluate(roomColor, robotType)
        
        if evalStatus.finished then
            Gather.init(roomColor, evalStatus.finalScore)
            state = STATES.GATHER
        end
    
    elseif (state == STATES.GATHER) then
        Gather.step()
    end
end

--[[
 Call init() in order to restore the program to its initial state.
--]]
function reset()
    init()
end

--[[
 This function is executed only once, when the robot is removed from the
 simulation.
--]]
function destroy()
end
