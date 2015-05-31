require "src/Movement"

--[[
 This file holds functions related to obstacle avoidance. The behaviour is the
 one seen in class, slightly modified (1st course exercise,
 obstacleAvoidance_vec).
--]]

--[[
  The obstacle vector must at least have a value superior to this constant in
  order to be considered significant.
--]]
local OBSTACLE_VALUE_THRESHOLD = 0.2

--[[
 Each proximity readings, in cylindrical coordinates, are treated as a vector.
 Return the sum of these vectors (adde head to tail).
--]]
function getObstacleVector(proximityTable)
    return headTailSumCylindricalVectors(proximityTable)
end

--[[
 Get opposite vector from obstacle vector.
 Returns a zero vector if the OBSTACLE_VALUE_THRESHOLD is not reached.
--]]
function getEscapeVector()
    local obstacleVector = getObstacleVector(robot.proximity)
    
    if (obstacleVector.value <= OBSTACLE_VALUE_THRESHOLD) then
        return { angle = 0, value = 0 }
    end
    
    return computeOppositeVector(obstacleVector)
end
