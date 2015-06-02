--[[
 Bytes used to send messages.
--]]

--[[
 Index of the byte reserved for the ping message. This type of message is sent
 by robots to notify their position. The position received from other robots is
 then used to compute the robots interaction vector.
 
 @see RobotsInteraction
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
