--[[
 This file holds a step function allowing to do obstacle avoidance. The behavior
 is the one seen in class (1st course exercise, obstacleAvoidance_vec).
--]]

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
 Use the proximity sensors to avoid obstacles. An obstacle vector is obtained
 by reading all the values from the sensors. We can then determine whether
 there's an obstacle, and whether the robot should turn right or left if it is
 the case. If no obstacle is detected, simply go straight.
 The robot turns with a speed that depends on the computed angle. The closer
 the obstacle is to the x axis of the robot, the quicker the turn.
--]]
function stepAvoid()
    local obstacleVector = getObstacleVector(robot.proximity)
    local obstacleDetected = (obstacleVector.value > 0.2)

    if obstacleDetected then
        -- Velocity which will be applied to the wheel corresponding to the
        -- side where the obstacle is.
        local velocity = math.max(0.5, math.cos(obstacleVector.angle)) * 10
        
        if obstacleVector.angle > 0 then
            -- obstacle on the left
            robot.wheels.set_velocity(velocity, 0)
        else
            -- obstacle on the right
            robot.wheels.set_velocity(0, velocity)
        end
    else
        robot.wheels.set_velocity(10,10)
    end
end
