G_ROBOT_COLOR = "yellow"
L_ROBOT_COLOR = "cyan"

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
