require "src/Messages"
require "src/Movement"
require "src/ObstacleAvoidance"

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
     TODO
    --]]
    function Gather.step()
        -- share position to other robots
        robot.range_and_bearing.set_data(I_BYTE_PING, 1)
        
        -- target (farthest robot)
        local targetVector = Gather.getFarthestRobot()
        
        -- escape vector (escape from obstacles)
        local escapeVector = getEscapeVector()
        
        -- sum
        local finalVector = headTailSumCylindricalVectors({
            targetVector, escapeVector
        })
        local speeds = computeSpeedsFromAngle(finalVector.angle)
        robot.wheels.set_velocity(speeds[1], speeds[2])
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
