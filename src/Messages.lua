require "src/Color"

--[[
 Functions related to sending and receiving messages.
--]]

--[[
 Index of the byte reserved for the ping message. This type of message is sent
 by robots to notify their position. The position received from other robots is
 then used to compute the robots interaction vector.
 
 @see TargetRoomFormation
--]]
I_BYTE_PING = 1

--[[
 Index of the bytes reserved for sharing a room color.
--]]
I_BYTE_RGB = {
    R = 2,
    G = 3,
    B = 4
}

--[[
 Index of the bytes reserved for sharing a partial score.
--]]
I_BYTE_PARTIAL = {
    L = 5,
    G = 6
}

--[[
 Index of the bytes reserved for sharing a final score.
--]]
I_BYTE_TOTAL = 7

--[[
 Receives Messages filtered by distance. If a received message comes from a
 robot positioned at a distance greater than the specificied threshold, this
 message is discarded.
--]]
function receiveMessages(distanceThreshold)
    local messages = {}
    
    for _,msg in ipairs(robot.range_and_bearing) do
        local thresholdExceeded = (msg.range > distanceThreshold)
            
        if (not thresholdExceeded) then
            table.insert(messages, msg)
        end
    end
    
    return messages
end

--[[
 Shares a score on the specified channel (scoreByte, use I_BYTE_PARTIAL.L,
 I_BYTE_PARTIAL.G or I_BYTE_TOTAL). The color of the room associated with the
 score is also sent (channel I_BYTE_RGB.R/.G/.B).
--]]
function shareScore(roomColor, scoreByte, score)
    robot.range_and_bearing.set_data(I_BYTE_RGB.R, roomColor.red)
    robot.range_and_bearing.set_data(I_BYTE_RGB.G, roomColor.green)
    robot.range_and_bearing.set_data(I_BYTE_RGB.B, roomColor.blue)
    robot.range_and_bearing.set_data(scoreByte, score)
end

--[[
 Receives partial scores (G and L) on the specified channel.
 Returns the best received score.
--]]
function receivePartialScores(roomColor)
    local best = { L = 0, G = 0 }
    
    for _,msg in ipairs(robot.range_and_bearing) do
        local msgRoomColor = msg.data[I_BYTE_RGB.R]
            .. msg.data[I_BYTE_RGB.G]
            .. msg.data[I_BYTE_RGB.B]
            
        if (roomColor.rgb == msgRoomColor) then
            local tmpL = msg.data[I_BYTE_PARTIAL.L]
            local tmpG = msg.data[I_BYTE_PARTIAL.G]
            
            best.L = math.max(best.L, tmpL)
            best.G = math.max(best.G, tmpG)
        end
    end
    
    return best
end
