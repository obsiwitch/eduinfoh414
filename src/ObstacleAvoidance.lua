--[[
 This file holds a step function allowing to do obstacle avoidance. The behavior
 is the one seen in class, slightly modified (1st course exercise,
 obstacleAvoidance_vec).
--]]

-- Max wheel speed
local WHEEL_SPEED = 10

-- Coefficient for computing the angular velocity
local K_PROP = 20;

-- Distance between the 2 wheels (in meters)
local WHEELS_DISTANCE = 0.14;

--[[
 Converts cylindrical coordinates to cartesian coordinates.
--]]
function cylindricalToCartesianCoords(cartesianCoords)
    return {
        x = cartesianCoords.value * math.cos(cartesianCoords.angle),
        y = cartesianCoords.value * math.sin(cartesianCoords.angle)
    }
end

--[[
 Converts cartesian coordinates to cylindrical coordinates.
--]]
function CartesianTocylindricalCoords(cylindricalCoords)
    return {
        value = math.sqrt(cylindricalCoords.x^2 + cylindricalCoords.y^2),
        angle = math.atan2(cylindricalCoords.y, cylindricalCoords.x)
    }
end

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
    
    local obstacleVector = CartesianTocylindricalCoords(accumulator)
    
    return obstacleVector
end

--[[
 Computes the speeds which need to be applied to both wheels in order to go in
 the direction of the specified angle.
 
 @note this function was seen during the 4th course exercise (pattern_formation)
--]]
function ComputeSpeedsFromAngle(angle)
    local forwardMotionCoeff
    local targetIsBehind = (angle > math.pi/2 or angle < -math.pi/2)
    
    -- Compute the forward motion coeffcieint ([0,1]) from the angle. If the
    -- target is behind the robot, we just rotate (no forward motion).
    if targetIsBehind then
        forwardMotionCoeff = 0.0;
    else
        forwardMotionCoeff = math.cos(angle)
    end

	 -- The angular velocity component is the desired angle scaled linearly.
    local angularVelocity = K_PROP * angle;
    
    return {
        forwardMotionCoeff * WHEEL_SPEED - angularVelocity * WHEELS_DISTANCE,
        forwardMotionCoeff * WHEEL_SPEED + angularVelocity * WHEELS_DISTANCE
    }
end

--[[
 Compute the opposite vector from a vector in cylindrical coordinates.
--]]
function ComputeOppositeVector(cylindricalVector)
    local oppositeAngle
    if (cylindricalVector.angle > 0) then
        oppositeAngle = cylindricalVector.angle - math.pi
    else
        oppositeAngle = cylindricalVector.angle + math.pi
    end
    
    return {
        value = -cylindricalVector.value,
        angle = oppositeAngle
    }
end

--[[
 Use the proximity sensors to avoid obstacles. An obstacle vector is obtained
 by reading all the values from the sensors. We can then avoid obstacles by
 going in the direction of the opposite vector.
--]]
function stepAvoid()
    local obstacleVector = getObstacleVector(robot.proximity)
    local escapeVector = ComputeOppositeVector(obstacleVector)
    local obstacleDetected = (obstacleVector.value > 0.2)

    if obstacleDetected then
        local speeds = ComputeSpeedsFromAngle(escapeVector.angle)
        robot.wheels.set_velocity(speeds[1], speeds[2])
    else
        robot.wheels.set_velocity(WHEEL_SPEED, WHEEL_SPEED)
    end
end
