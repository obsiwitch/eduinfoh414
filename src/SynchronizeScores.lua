require "src/Color"
require "src/Messages"
require "src/Bot"

Synchronize = {}

--[[
 Initializes Synchronize singleton.
--]]
function Synchronize.init(partialScore, roomColor)
    --- Constants
    
    --[[
     If no improvement has been made to the scores for this number of steps,
     then we assume the obtained scores are the correct one.
    --]]
    local MAX_STEPS_NO_IMPROVEMENT = 50
    
    local STATES = {
        INIT_SYNC_PARTIAL = 0,
        SUM_PARTIAL = 1,
        SYNC_TOTAL = 2
    }
    
    --- Private attributes
    
    local bestRoomColor = roomColor
    local bestRoomScore = 0
    
    local partialScores = {}
    if (Bot.type == "G") then
        partialScores.G = partialScore
        partialScores.L = 0
    else
        partialScores.G = 0
        partialScores.L = partialScore
    end
    
    -- Number of steps during which no improvement has been made to the score.
    local steps = 0
    
    local state = STATES.SYNC_PARTIAL
    
    --- Public methods
    
    --[[
     Synchronize scores:
     1) share and retrieve partial scores for the robot's associated room
     2) sum partial scores to obtain total score
     3) share, retrieve and keep the best score
    --]]
    function Synchronize.step()
        if (state == STATES.INIT_SYNC_PARTIAL) then
            -- Share the current partial score one time
            shareScore(roomColor, I_BYTE_PARTIAL[Bot.type], partialScore)
            
            state = STATES.SYNC_PARTIAL
        
        elseif (state == STATES.SYNC_PARTIAL) then
            local sharedPartialScores = Synchronize.receivePartialScores(bestRoomColor)
            local partialScoreUpdated = (
                (sharedPartialScores.L > partialScores.L) or
                (sharedPartialScores.G > partialScores.G)
            )
            
            -- partial score update
            partialScores.L = math.max(partialScores.L, sharedPartialScores.L)
            partialScores.G = math.max(partialScores.G, sharedPartialScores.G)
            
            -- share partial score
            shareScore(roomColor, I_BYTE_PARTIAL[Bot.type], partialScore)
            
            -- steps counter update
            if partialScoreUpdated then
                steps = 0
            else
                steps = steps + 1
            end
            
            if (steps > MAX_STEPS_NO_IMPROVEMENT) then
                state = STATES.SUM_PARTIAL
            end
            
        elseif (state == STATES.SUM_PARTIAL) then
            -- compute total score from both partial scores
            bestRoomScore = (partialScores.L + partialScores.G)/2
            
            steps = 0
            
            state = STATES.SYNC_TOTAL
            
        elseif(state == STATES.SYNC_TOTAL) then
            -- retrieve and compare best score from neighbouring robots to
            -- current best score
            local sharedBestRoom = Synchronize.receiveFinalScores()
            if (sharedBestRoom.score > bestRoomScore) then
                bestRoomScore = sharedBestRoom.score
                bestRoomColor = sharedBestRoom.color
                
                steps = 0
            else
                steps = steps + 1
            end
            
            -- share current best score
            shareScore(bestRoomColor, I_BYTE_TOTAL, bestRoomScore)
            
            if (steps > MAX_STEPS_NO_IMPROVEMENT) then
                robot.leds.set_all_colors(EVALUATED.colorName)
                return bestRoomColor
            else
                robot.leds.set_all_colors(PARTIALLY_EVALUATED.colorName)
                return nil
            end
        end
        
        return nil
    end
    
    --[[
     Receives partial scores (G and L). Returns the best received scores.
     If a robotType is given in parameter, only return the best partial score for
     this type of robot.
    --]]
    function Synchronize.receivePartialScores(roomColor, robotType)
        local best = { L = 0, G = 0 }
        
        for _,msg in ipairs(robot.range_and_bearing) do
            local msgRoomColor = Color.new({
                red = msg.data[I_BYTE_RGB.R],
                green = msg.data[I_BYTE_RGB.G],
                blue = msg.data[I_BYTE_RGB.B]
            })
            
            if Color.eq(roomColor, msgRoomColor) then
                local tmpL = msg.data[I_BYTE_PARTIAL.L]
                local tmpG = msg.data[I_BYTE_PARTIAL.G]
                
                best.L = math.max(best.L, tmpL)
                best.G = math.max(best.G, tmpG)
            end
        end
        
        if (robotType == nil) then
            return best
        else
            return best[robotType]
        end
    end
    
    --[[
     Receives rooms final score. Returns the best received one, as well as the
     associated room's color.
    --]]
    function Synchronize.receiveFinalScores()
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
     Returns true if all neighbouring robots have evaluated totally their
     associated room, else false.
    --]]
    function Synchronize.checkEvalStatusRobots()
        for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
            local vColor = Color.new(v.color)
            if Color.eq(vColor, PARTIALLY_EVALUATED) then
                return false
            end
        end
        
        return true
    end
end
