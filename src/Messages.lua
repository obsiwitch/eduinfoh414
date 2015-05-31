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
 Index of the byte reserved for sharing a final score.
--]]
I_BYTE_TOTAL = 7

--[[
 Index of the byte reserved for sharing the evaluation status of a room.
 * 1 -> not evaluated
 * 2 -> evaluated
--]]
I_BYTE_ROOM_EVAL = 8

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
 Converts a score in [0,1] to a value in [0,255].
--]]
function convertScoreToByte(score)
    return math.floor(255 * score)
end
