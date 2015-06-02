-- current robot
Bot = {}

function Bot.init()
    --[[ Constants ]]
    
    -- Max wheel speed
    local WHEEL_SPEED = 20

    -- Coefficient for computing the angular velocity
    local K_PROP = 20;

    -- Distance between the 2 wheels (in meters)
    local WHEELS_DISTANCE = 0.14;
    
    --[[ Private methods ]]
    
    -- "L": Light robot or "G": Ground robot
    function getType()
        if (robot.motor_ground ~= nil) then
            return "G"
        elseif (robot.light ~= nil) then
            return "L"
        end
    end
    
    --[[
     Computes the speeds which need to be applied to both wheels in order to go
     in the direction of the specified angle.
     
     @note this function was seen during the 4th course exercise (pattern
     formation)
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
     Determines whether the target is behind the robot (angle in [-pi/3 ; pi/3])
     or not.
    --]]
    function targetIsBehindRobot(targetAngle)
        return (targetAngle > math.pi/3 or targetAngle < -math.pi/3)
    end
    
    --[[ Public methods ]]
    
    --[[
     Move the robot in direction pointed by the angle.
    --]]
    function Bot.goTowardsAngle(angle)
        local speeds = computeSpeedsFromAngle(angle)
        robot.wheels.set_velocity(speeds[1], speeds[2])
    end
    
    --[[ Initial behaviour ]]
    
    -- enable camera
    robot.colored_blob_omnidirectional_camera.enable()
    
    -- share position to other robots
    robot.range_and_bearing.set_data(I_BYTE_PING, 1)
    
    --[[ Public attributes ]]
    
    Bot.type = getType()
    
    -- Room associated with this robot
    Bot.roomColor = nil
end
