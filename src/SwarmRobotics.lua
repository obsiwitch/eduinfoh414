require "src/RobotType"
require "src/RoomDetection"
require "src/ObstacleAvoidance"

--[[
 Set of rooms which need to be explored. This set is filled at the beginning
 by using the camera to detect doors.
 
 Example of element contained in the set: ["25500"] = false
--]]
rooms = {}

--[[
 Current robot's type (G or L).
 Initialized to U (unknown) and then sets it to its correct value in the init()
 function.
--]]
robotType = "U"

--[[
 Detects the rooms and retrieves the current robot's type.
--]]
function init()
    robot.colored_blob_omnidirectional_camera.enable()
    
    rooms = detectRooms()
    
    robotType = getRobotType()
    setRobotColor(robotType)
end

--[[
 This function is executed at each time step. It must contain the logic of your
 controller
--]]
function step()
    stepAvoid()
end

--[[
 This function is executed every time you press the 'reset' button in the GUI.
 It is supposed to restore the state of the controller to whatever it was right
 after init() was called. The state of sensors and actuators is reset
 automatically by ARGoS.
--]]
function reset()
   init()
   resetAvoid()
end

--[[
 This function is executed only once, when the robot is removed from the
 simulation.
--]]
function destroy()
end
