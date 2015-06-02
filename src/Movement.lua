--[[
  This file holds functions related to robots movement and coordinates systems.
--]]

-- Max wheel speed
WHEEL_SPEED = 20

-- Coefficient for computing the angular velocity
local K_PROP = 20;

-- Distance between the 2 wheels (in meters)
local WHEELS_DISTANCE = 0.14;

--[[
 Converts polar coordinates to cartesian coordinates.
--]]
function polarToCartesianCoords(cartesianCoords)
    return {
        x = cartesianCoords.value * math.cos(cartesianCoords.angle),
        y = cartesianCoords.value * math.sin(cartesianCoords.angle)
    }
end

--[[
 Converts cartesian coordinates to polar coordinates.
--]]
function cartesianTopolarCoords(polarCoords)
    return {
        value = math.sqrt(polarCoords.x^2 + polarCoords.y^2),
        angle = math.atan2(polarCoords.y, polarCoords.x)
    }
end

--[[
 Determines whether the target is behind the robot (angle in [-pi/3 ; pi/3])
 or not.
--]]
function targetIsBehindRobot(targetAngle)
    return (targetAngle > math.pi/3 or targetAngle < -math.pi/3)
end

--[[
 Computes the speeds which need to be applied to both wheels in order to go in
 the direction of the specified angle.
 
 @note this function was seen during the 4th course exercise (pattern_formation)
--]]
function computeSpeedsFromAngle(angle)
    local forwardMotionCoeff
    
    -- Compute the forward motion coeffcient ([0,1]) from the angle. If the
    -- target is behind the robot, we just rotate (no forward motion).
    if targetIsBehindRobot(angle) then
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
 Compute the opposite vector from a vector in polar coordinates.
--]]
function computeOppositeVector(polarVector)
    local oppositeAngle
    if (polarVector.angle > 0) then
        oppositeAngle = polarVector.angle - math.pi
    else
        oppositeAngle = polarVector.angle + math.pi
    end
    
    return {
        value = polarVector.value,
        angle = oppositeAngle
    }
end

--[[
 Sum polar vectors head to tail.
 Converts the 2 vectors into cartesian coordinates, sum them and convert them
 back to polar coordinates.
--]]
function headTailSumPolarVectors(vectors)
    local accumulator = { x = 0, y = 0 }
    
    for _,v in ipairs(vectors) do
        local vXY = polarToCartesianCoords(v)
        
        accumulator.x = accumulator.x + vXY.x
        accumulator.y = accumulator.y + vXY.y
    end
    
    return cartesianTopolarCoords(accumulator)
end
