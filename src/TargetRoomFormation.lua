require "src/Color"
require "src/Messages"
require "src/ObstacleAvoidance"
require "src/RoomDetection"

--[[
 Holds functions to organize robots inside a target room.
 The main ideas for pattern formation were seen in class during the 4th
 exercise.
--]]

--[[
 Target distance between robots (cm). Used by the Lennard-Jones potential.
--]]
local TARGET_DIST = 50

--[[
 Well depth, the deeper, the stronger the interaction.
 Increasing this coefficient increases the repulsion/attraction of the
 Lennard-Jones force.
--]]
local EPSILON = 20

--[[
 This function should be used when robots are already inside a target room.
 Its purpose is to group robots inside their current target room between the
 light source and the door.
 G robots will be attracted by the door, while L robots will be attracted by
 the light source.
--]]
function stepTargetRoomFormation(robotType)
    -- share position to other robots
    robot.range_and_bearing.set_data(I_BYTE_PING, 1)
    
    -- target vector (door or light source)
    local targetVector = computeTargetVector(robotType)
    
    -- escape vector (escape from obstacles)
    local escapeVector = getEscapeVector()
    
    -- robots interaction
    local robotsInteractionVector = computeRobotsInteraction()
    
    -- sum
    local finalVector = headTailSumCylindricalVectors({
        targetVector, escapeVector, robotsInteractionVector
    })
    local speeds = computeSpeedsFromAngle(finalVector.angle)
    robot.wheels.set_velocity(speeds[1], speeds[2])
end

--[[
 Computes the target vector depending on the robot's type.
 For a Ground type robot, the target is the door.
 For a Light type robot, the target is the light source.
--]]
function computeTargetVector(robotType)
    if (robotType == "G") then
        local nearestDoor = getNearestDoor()

        return {
            value = nearestDoor.distance,
            angle = nearestDoor.angle
        }
        
    elseif (robotType == "L") then
        local nearestLightSource = getNearestElement(LIGHT_SOURCE_COLOR.rgb)
        
        if (nearestLightSource ~= nil) then
            return {
                value = nearestLightSource.distance,
                angle = nearestLightSource.angle,
            }
        end
    end
    
    return { value = 0, angle = 0 }
end

--[[
 Computes a cylindrical coordinates vector representing attractions and
 repulsion between robots.
--]]
function computeRobotsInteraction()
    local accumulator = { x = 0, y = 0 }
    
    for _,msg in ipairs(robot.range_and_bearing) do
        if msg.data[I_BYTE_PING] == 1 then
            local cartesianVector = cylindricalToCartesianCoords({
                value = computeLennardJonesForce(msg.range),
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
function computeLennardJonesForce(distance)
    return -4 * EPSILON/distance * (
        math.pow(TARGET_DIST/distance, 4)
        - math.pow(TARGET_DIST/distance, 2)
    );
end
