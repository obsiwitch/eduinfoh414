require "src/Environment"
require "src/Gather"
require "src/RobotsInteraction"
require "src/Movement"
require "src/Color"

BestRoomFormation = {}

-- Initializes BestRoomFormation singleton.
function BestRoomFormation.init()
    --- Constants
    
    --[[ maximum distance allowed for accepting elements (i.e. light source,
     objects) as anchors for the robots.
    --]]
    local MAX_DIST_ELEMENTS = 150
    
    --- Public methods
    
    --[[
     Robots enter the best room and stay in it by being attracted by various
     elements in the room (i.e. light source, objects, other robots).
     
     Forces order:
     F_nearestLightSource > F_nearestObject > F_farthestRobot > F_robotsInteraction
     
     FIXME robots wandering outside the room
    --]]
    function BestRoomFormation.step()
        local nearestLightSource = getNearestElement(LIGHT_SOURCE_COLOR)
        nearestLightSource = nearestLightSource or { distance = 0, angle = 0}
        if (nearestLightSource.distance < MAX_DIST_ELEMENTS) then
            nearestLightSource.value = nearestLightSource.distance * 100
        else
            nearestLightSource.value = 0
        end
        
        local nearestObject = getNearestElement(OBJECT_COLOR)
        nearestObject = nearestObject or { distance = 0, angle = 0}
        if (nearestObject.distance < MAX_DIST_ELEMENTS) then
            nearestObject.value = nearestObject.distance * 10
        else
            nearestObject.value = 0
        end
        
        local farthestRobot = Gather.getFarthestRobot()
        
        -- Additionally to the farthestRobot vector, compute the
        -- robotsInteraction vector in order to bind robots using the
        -- range_and_bearing system. Prevents problems that occurs sometimes
        -- when the previous elements are not detected by the camera.
        local robotsInteraction = computeRobotsInteraction()
        
        -- sum
        local finalVector = headTailSumCylindricalVectors({
            nearestLightSource, nearestObject, robotsInteraction, farthestRobot
            --farthestRobot
        })
        local speeds = computeSpeedsFromAngle(finalVector.angle)
        robot.wheels.set_velocity(speeds[1], speeds[2])
    end
end
