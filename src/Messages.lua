--[[
 Functions related to sending and receiving messages.
--]]

--[[
 Broadcasts a message. The first byte will be used to indicate the type of
 message, and the other bytes will contain the message itself.
--]]
function sendMessage(type, data)
    robot.range_and_bearing.set_data(1, type)
    
    for i=2, math.min(#data, 10) do
        robot_range_and_bearing.set_data(i, data[i])
    end
end

--[[
 Receive messages of a specific type.
 Messages can also be filtered by distance (optional). If a received message
 comes from a robot positioned at a distance greater than the specificied
 threshold, this message is discarded.
--]]
function receiveMessages(type, distanceThreshold)
    local messages = {}
    
    for _,msg in ipairs(robot.range_and_bearing) do
        local thresholdExceeded = (distanceThreshold ~= nil) and
            (msg.range > distanceThreshold)
            
        if (msg.data[1] == type) and (not thresholdExceeded) then
            table.insert(messages, msg)
        end
    end
    
    return messages
end
