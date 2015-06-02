require "src/Messages"
require "src/VectorOps"
require "src/ObstacleAvoidance"
require "src/RobotsInteraction"

Gather = {}

--[[
 Initializes the Gather singleton.
--]]
function Gather.init()
    -- Constants
    
    --[[
     Target distance between robots (cm).
    --]]
    local TARGET_DIST = 10
    
    --[[
     Well depth, the deeper, the stronger the interaction.
     Increasing this coefficient increases the repulsion/attraction of the
     Lennard-Jones force.
    --]]
    local EPSILON = 20
    
    -- Public methods
    
    --[[
     Gather robots to easily exchange information.
    --]]
    function Gather.step()
        -- target (farthest robot)
        local targetVector = Gather.getFarthestRobot()
        
        -- escape vector (escape from obstacles)
        local escapeVector = getEscapeVector()
        
        -- robots interaction (avoid blocking other robots)
        local robotsInteraction = computeRobotsInteraction()
        
        -- sum
        local finalVector = headTailSumPolarVectors({
            targetVector, escapeVector, robotsInteraction
        })
        Bot.goTowardsAngle(finalVector.angle)
    end
    
    --[[
     Computes a vector in polar coordinates representing attraction towards the
     furthest robot.
    --]]
    function Gather.getFarthestRobot()
        local furthestRobot = { value = 0, angle = 0 }
        
        for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
            local vColor = Color.new(v.color)
            local isRobot = (
                Color.eq(vColor, PARTIALLY_EVALUATED) or
                Color.eq(vColor, EVALUATED)
            )
            
            if isRobot and (v.distance > furthestRobot.value) then
                furthestRobot.value = v.distance
                furthestRobot.angle = v.angle
            end
        end
        
        return furthestRobot
    end
end
