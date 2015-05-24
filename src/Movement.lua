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
