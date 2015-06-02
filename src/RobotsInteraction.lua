require "src/Movement"

--[[
 Target distance between robots (cm). Used by the Lennard-Jones potential.
--]]
local TARGET_DIST = 20

--[[
 Well depth, the deeper, the stronger the interaction.
 Increasing this coefficient increases the repulsion/attraction of the
 Lennard-Jones force.
--]]
local EPSILON = 20

--[[
 Computes a polar coordinates vector representing attractions and repulsion
 between robots.
--]]
function computeRobotsInteraction(targetDistance)
    targetDistance = targetDistance or TARGET_DIST
    local accumulator = { x = 0, y = 0 }
    
    for _,msg in ipairs(robot.range_and_bearing) do
        if msg.data[I_BYTE_PING] == 1 then
            local cartesianVector = cylindricalToCartesianCoords({
                value = computeLennardJonesForce(msg.range, targetDistance),
                angle = msg.horizontal_bearing
            })
            
            accumulator.x = accumulator.x + cartesianVector.x
            accumulator.y = accumulator.y + cartesianVector.y
        end
    end
    
    return cartesianTocylindricalCoords(accumulator)
end

--[[
 Computes the Lennard-Jones force.
--]]
function computeLennardJonesForce(distance, targetDistance)
    return -4 * EPSILON/distance * (
        math.pow(targetDistance/distance, 4)
        - math.pow(targetDistance/distance, 2)
    );
end
