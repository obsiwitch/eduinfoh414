require "src/Messages"
require "src/Movement"
require "src/ObstacleAvoidance"

Gather = {}

--[[
 Initializes the Gather singleton.
--]]
function Gather.init(roomColor, roomScore)
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
    
    -- Private attributes
    
    local bestRoomColor = roomColor
    local bestRoomScore = roomScore
    
    -- Public methods
    
    --[[
     Group robots and synchronize them to the best known score.
     The more robots are far, the more they are attracted.
    --]]
    function Gather.step()
        -- share position to other robots
        robot.range_and_bearing.set_data(I_BYTE_PING, 1)
        
        -- retrieve and compare best score from neighbouring robots to current
        -- best score
        local sharedBestRoom = Gather.receiveFinalScores()
        if (sharedBestRoom.score > bestRoomScore) then
            bestRoomScore = sharedBestRoom.score
            bestRoomColor = sharedBestRoom.color
        end
        
        -- share current best score
        shareScore(bestRoomColor, I_BYTE_TOTAL, bestRoomScore)
        
        -- target (farthest robot)
        local targetVector = Gather.computeTargetRobot()
        
        local speeds = computeSpeedsFromAngle(targetVector.angle)
        robot.wheels.set_velocity(speeds[1], speeds[2])
    end
    
    --[[
     Receives rooms final score. Returns the best received one, as well as the
     associated room's color.
    --]]
    function Gather.receiveFinalScores()
        local best = { color = nil, score = 0 }
        
        for _,msg in ipairs(robot.range_and_bearing) do
            local msgRoomColor = Color.new({
                red = msg.data[I_BYTE_RGB.R],
                green = msg.data[I_BYTE_RGB.G],
                blue = msg.data[I_BYTE_RGB.B]
            })
            
            local msgRoomScore = msg.data[I_BYTE_TOTAL]
            
            if (best.score < msgRoomScore) then
                best.color = msgRoomColor
                best.score = msgRoomScore
            end
        end
        
        return best
    end
    
    --[[
     Computes a vector in polar coordinates representing attraction towards the
     furthest robot.
    --]]
    function Gather.computeTargetRobot()
        local furthestRobot = { value = 0, angle = 0 }
        
        for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
            local vColor = v.color.red .. v.color.green .. v.color.blue
            local isRobot = (
                (vColor == G_ROBOT_COLOR.rgb) or
                (vColor == L_ROBOT_COLOR.rgb)
            )
            
            if isRobot and (v.distance > furthestRobot.value) then
                furthestRobot.value = v.distance
                furthestRobot.angle = v.angle
            end
        end
        
        return furthestRobot
    end
end
