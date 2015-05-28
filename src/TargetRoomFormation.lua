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
 Type of message sent by robots in order to notify their position.
--]]
local MSG_TYPE_PING = 1

--[[
 This function should be used when robots are already inside a target room.
 Its purpose is to group robots inside their current target room between the
 light source and the door.
 G robots will be attracted by the door, while L robots will be attracted by
 the light source.
--]]
function stepTargetRoomFormation(robotType)
    -- share position to other robots
    sendMessage(MSG_TYPE_PING, {})
    
    -- target vector
    local targetVector = computeTargetVector(robotType)
    
    -- escape vector
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

    for _,v in ipairs(receiveMessages(MSG_TYPE_PING)) do
        local cartesianVector = cylindricalToCartesianCoords({
            value = computeLennardJonesForce(v.range),
            angle = v.horizontal_bearing
        })
        
        accumulator.x = accumulator.x + cartesianVector.x
        accumulator.y = accumulator.y + cartesianVector.y
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
