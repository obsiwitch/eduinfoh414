ROOM_COLORS = {"magenta", "blue", "orange", "red"}
G_ROBOT_COLOR = "yellow"
L_ROBOT_COLOR = "cyan"

--[[
 Current robot's type (G or L).
 Initialized to U (unknown) and then set to its correct value in the init()
 function.
--]]
robotType = "U"

--[[
 Gets the current robot's type.
 * type G: ground sensor
 * type L: light sensor
 * type U: unknown
--]]
function getRobotType()
    if (robot.motor_ground ~= nil) then
        return "G"
    elseif (robot.light ~= nil) then
        return "L"
    else
        return "U"
    end
end

--[[
 Sets the robot's color depending on its type.
 * type G: yellow
 * type L: cyan
--]]
function setRobotColor(robotType)
	if (robotType == "G") then
		robot.leds.set_all_colors(G_ROBOT_COLOR)
	elseif (robotType == "L") then
		robot.leds.set_all_colors(L_ROBOT_COLOR)
	end
end

--[[
 This function is executed every time you press the 'execute' button.
--]]
function init()
	robotType = getRobotType()
	setRobotColor(robotType)
end

--[[
 This function is executed at each time step. It must contain the logic of your
 controller
--]]
function step()
    -- TODO
end

--[[
 This function is executed every time you press the 'reset' button in the GUI.
 It is supposed to restore the state of the controller to whatever it was right
 after init() was called. The state of sensors and actuators is reset
 automatically by ARGoS.
--]]
function reset()
   init()
end

--[[
 This function is executed only once, when the robot is removed from the
 simulation.
--]]
function destroy()
   -- TODO
end
