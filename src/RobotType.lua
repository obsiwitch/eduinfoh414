require "src/Color"

--[[
 Gets the current robot's type.
 * type G: ground sensor
 * type L: light sensor
--]]
function getRobotType()
    if (robot.motor_ground ~= nil) then
        return "G"
    elseif (robot.light ~= nil) then
        return "L"
    end
end
