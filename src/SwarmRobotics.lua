-- TODO clean requires
require "src/RobotType"
require "src/RoomDetection"
require "src/MoveRoom"

--[[
 Table listing the diffrent states a robot can enter.
 * INIT_ROOMS: initializes the rooms set using the camera at the beginning
 of the program.
 * AVOID: obstacle avoidance, move randomly inside the environment
--]]
local STATES = {
    ["UNKNOWN"] = -1,
    ["INIT_ROOMS"] = 0,
    ["AVOID"] = 1
}

-- Current state
local state = STATES["UNKNOWN"]

--[[
 Set of rooms which need to be explored. This set is filled at the beginning
 by using the camera to detect doors.
 
 Example of element contained in the set (red room): ["25500"] = false
--]]
local rooms = {}

--[[
 Current robot's type (G or L) (U = unknown).
--]]
local robotType = "U"

--[[
 Enables the camera and initialize variables (i.e. state, robotType).
--]]
function init()
    robot.colored_blob_omnidirectional_camera.enable()
    
    state = STATES["INIT_ROOMS"]
    
    robotType = getRobotType()
    setRobotColor(robotType)
end

--[[
 State machine executed at each time step.
 @see STATES
--]]
function step()
    if (state == STATES["INIT_ROOMS"]) then
        rooms = detectRooms()
        initMoveIntoRoom("25500")
        state = STATES["AVOID"]
    elseif (state == STATES["AVOID"]) then
        stepMoveIntoRoom()
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
