require "src/Movement"

--[[
 This file holds functions related to obstacle avoidance. The behaviour is the
 one seen in class, slightly modified (1st course exercise,
 obstacleAvoidance_vec).
--]]

--[[
 Each proximity readings, in cylindrical coordinates, are treated as a vector.
 Return the sum of these vectors (adde head to tail).
--]]
function getObstacleVector(proximityTable)
    return headTailSumCylindricalVectors(proximityTable)
end

--[[
 Get opposite vector from obstacle vector.
--]]
function getEscapeVector()
    return computeOppositeVector(
        getObstacleVector(robot.proximity)
    )
end

--[[
 Use the proximity sensors to avoid obstacles. An obstacle vector is obtained
 by reading all the values from the sensors. We can then avoid obstacles by
 going in the direction of the opposite vector.
--]]
function stepAvoid()
    local escapeVector = getEscapeVector()
    local obstacleDetected = (escapeVector.value > 0.2)

    if obstacleDetected then
        local speeds = computeSpeedsFromAngle(escapeVector.angle)
        robot.wheels.set_velocity(speeds[1], speeds[2])
    else
        robot.wheels.set_velocity(WHEEL_SPEED, WHEEL_SPEED)
    end
end
