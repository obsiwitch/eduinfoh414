require "src/Color"
require "src/Messages"
require "src/EvaluateRoom"

Synchronize = {}

--[[
 Initializes Synchronize singleton.
--]]
function Synchronize.init(robotType, partialScore, roomColor)
    --- Constants
    
    local STATES = {
        SUM_PARTIAL = 0,
        SYNC_TOTAL = 1
    }
    
    --- Private attributes
    
    local robotType = robotType -- FIXME useless?
    local bestRoomColor = roomColor
    local bestRoomScore = 0
    
    local partialScores = {}
    if (robotType == "G") then
        partialScores.G = partialScore
        partialScores.L = 0
    else
        partialScores.G = 0
        partialScores.L = partialScore
    end
    
    local state = STATES.SUM_PARTIAL
    
    --- Public methods
    
    --[[
     TODO
    --]]
    function Synchronize.step()
        if (state == STATES.SUM_PARTIAL) then
            local sharedPartialScores = Evaluate.receivePartialScores(
                bestRoomColor)
            
            partialScores.L = math.max(partialScores.L, sharedPartialScores.L)
            partialScores.G = math.max(partialScores.G, sharedPartialScores.G)
            
            -- FIXME approximation, the ground value could be 0
            local missingPartialG = (partialScores.G == 0)
            local missingPartialL = (partialScores.L == 0)
            
            if (not missingPartialL) and (not missingPartialL) then
                bestRoomScore = (partialScores.L + partialScores.G)/2
                state = STATES.SYNC_TOTAL
                
                -- no partial score missing
                robot.range_and_bearing.set_data(I_BYTE_EVAL_STATUS, 0)
                
                -- TODO return
            else
                -- share that a partial score is missing
                if missingPartialG then
                    robot.range_and_bearing.set_data(I_BYTE_EVAL_STATUS, 1)
                else
                    robot.range_and_bearing.set_data(I_BYTE_EVAL_STATUS, 2)
                end
                
                -- TODO return
            end
            
        elseif(state == STATES.SYNC_TOTAL) then
            -- retrieve and compare best score from neighbouring robots to
            -- current best score
            local sharedBestRoom = Synchronize.receiveFinalScores()
            if (sharedBestRoom.score > bestRoomScore) then
                bestRoomScore = sharedBestRoom.score
                bestRoomColor = sharedBestRoom.color
            end
            
            -- share current best score
            shareScore(bestRoomColor, I_BYTE_TOTAL, bestRoomScore)
            
            -- detect missing partial score
            local missingRoomColor = Synchronize.receiveMissingScoreNotif(
                robotType)
            if (missingRoomColor ~= nil) then
                log(missingRoomColor.rgb)
                -- TODO do something with the returned missingRoomColor
                robot.leds.set_all_colors(PARTIALLY_EVALUATED.colorName)
            else
                robot.leds.set_all_colors(EVALUATED.colorName)
            end
            
            -- TODO return
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
     Receives notification that there is a missing partial score.
     Returns the room color associated with the notification. Only returns
     notifications concerning a robot of opposite to the current one.
    --]]
    function Synchronize.receiveMissingScoreNotif(robotType)
        for _,msg in ipairs(robot.range_and_bearing) do
            local msgRoomColor = Color.new({
                red = msg.data[I_BYTE_RGB.R],
                green = msg.data[I_BYTE_RGB.G],
                blue = msg.data[I_BYTE_RGB.B]
            })
            
            if (msg.data[I_BYTE_EVAL_STATUS] == 1 and robotType == "L") or
               (msg.data[I_BYTE_EVAL_STATUS] == 2 and robotType == "G")
            then
                return msgRoomColor
            end
        end
        
        return nil
    end
end
