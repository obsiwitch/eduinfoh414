require "src/Movement"

--[[
 This file holds functions related to obstacle avoidance. The behaviour is the
 one seen in class, slightly modified (1st course exercise,
 obstacleAvoidance_vec).
--]]

--[[
 Each proximity readings, in cylindrical coordinates, are treated as a vector.
 We want to head-tail add all these vectors in order to obtain the obstacle
 vector. In order to do so, we must convert the proximity readings into
 cartesian coordinates.
 Returns the obstacle vector in cylindrical coordinates.
--]]
function getObstacleVector(proximityTable)
    local accumulator = {x = 0, y = 0}
    
    for _,proximity in ipairs(proximityTable) do
        local cartesianCoords = cylindricalToCartesianCoords(proximity)
        
        accumulator.x = accumulator.x + cartesianCoords.x
        accumulator.y = accumulator.y + cartesianCoords.y
    end
    
    local obstacleVector = cartesianTocylindricalCoords(accumulator)
    
    return obstacleVector
end

--[[
 Use the proximity sensors to avoid obstacles. An obstacle vector is obtained
 by reading all the values from the sensors. We can then avoid obstacles by
 going in the direction of the opposite vector.
--]]
function stepAvoid()
    local obstacleVector = getObstacleVector(robot.proximity)
    local escapeVector = computeOppositeVector(obstacleVector)
    local obstacleDetected = (obstacleVector.value > 0.2)

    if obstacleDetected then
        local speeds = computeSpeedsFromAngle(escapeVector.angle)
        robot.wheels.set_velocity(speeds[1], speeds[2])
    else
        robot.wheels.set_velocity(WHEEL_SPEED, WHEEL_SPEED)
    end
end
