--[[
  This file holds functions related to robots movement.
--]]

-- Max wheel speed
WHEEL_SPEED = 10

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
function cartesianTocylindricalCoords(cylindricalCoords)
    return {
        value = math.sqrt(cylindricalCoords.x^2 + cylindricalCoords.y^2),
        angle = math.atan2(cylindricalCoords.y, cylindricalCoords.x)
    }
end

--[[
 Determines whether the target is behind the robot or not.
--]]
function targetIsBehindRobot(targetAngle)
    return (targetAngle > math.pi/2 or targetAngle < -math.pi/2)
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
 Compute the opposite vector from a vector in cylindrical coordinates.
--]]
function computeOppositeVector(cylindricalVector)
    local oppositeAngle
    if (cylindricalVector.angle > 0) then
        oppositeAngle = cylindricalVector.angle - math.pi
    else
        oppositeAngle = cylindricalVector.angle + math.pi
    end
    
    return {
        value = cylindricalVector.value,
        angle = oppositeAngle
    }
end
