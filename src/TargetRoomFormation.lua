require "src/Color"
require "src/Messages"
require "src/Movement"
require "src/ObstacleAvoidance"
require "src/Environment"
require "src/RobotsInteraction"

--[[
 Holds functions to organize robots inside a target room.
 The main ideas for pattern formation were seen in class during the 4th
 exercise.
--]]

--[[
 This function should be used when robots are already inside a target room.
 Its purpose is to group robots inside their current target room between the
 light source and the door.
 G robots will be attracted by the door, while L robots will be attracted by
 the light source.
--]]
function stepTargetRoomFormation(robotType)
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
        local nearestLightSource = getNearestElement(LIGHT_SOURCE_COLOR)
        
        if (nearestLightSource ~= nil) then
            return {
                value = nearestLightSource.distance,
                angle = nearestLightSource.angle,
            }
        end
    end
    
    return { value = 0, angle = 0 }
end
