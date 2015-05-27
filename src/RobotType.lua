G_ROBOT_COLOR = {
    colorName = "yellow",
    rgb = "2552550"
}

L_ROBOT_COLOR = {
    colorName = "cyan",
    rgb = "0255255"
}

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
        robot.leds.set_all_colors(G_ROBOT_COLOR.colorName)
    elseif (robotType == "L") then
        robot.leds.set_all_colors(L_ROBOT_COLOR.colorName)
    end
end
