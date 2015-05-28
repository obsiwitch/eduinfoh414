--[[
 Functions related to sending and receiving messages.
--]]

--[[
 Index of the byte reserved for the ping message. This type of message is sent
 by robots to notify their position. The position received from other robots is
 then used to compute the robots interaction vector.
--]]
I_BYTE_PING = 1

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
