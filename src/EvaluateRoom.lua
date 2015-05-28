require "src/RoomDetection"

--[[
 Evaluates the ground color. Returns all the different ground colors detected by
 the ground (e.g. if the 4 sensors detect the same color, only return one
 color).
--]]
function evaluateGround()
    -- unique values using a set
    local set = {}
    for _,v in pairs(robot.motor_ground) do
        if (set[v.value] == nil) then
            set[v.value] = true
        end
    end
    
    -- transfer the set elements in a number indexed table
    local groundEvaluation = {}
    for k,_ in pairs(set) do
        table.insert(groundEvaluation, k)
    end
    
    return groundEvaluation
end

--[[
 Evaluates the light of a room by returning the highest value retrieved from
 the sensors.
--]]
function evaluateLight()
    local highestValue = 0
    
    for _,v in pairs(robot.light) do
        if (v.value > highestValue) then
            highestValue = v.value
        end
    end
    
    return highestValue
end

--[[
 Returns whether the specified element is contained in the target room or not.
 The nearest door is used as a reference to determine the limit of the room.
 
 @note This function will only work as intended in a target room, because this
 type of room only has one door. This function relies on the fact that the room
 only has one door, so it will not work if it is used in the central room.
--]]
function elementInTargetRoom(element, nearestDoor)
    local elementIsBehindRobot = targetIsBehindRobot(element.angle)
    local doorIsBehindRobot = targetIsBehindRobot(nearestDoor.angle)
    
    local elementXY = cylindricalToCartesianCoords({
        value = element.distance,
        angle = element.angle
    })
    
    local doorXY = cylindricalToCartesianCoords({
        value = nearestDoor.distance,
        angle = nearestDoor.angle
    })
    
    return (
        (doorIsBehindRobot and not elementIsBehindRobot) or
        (not doorIsBehindRobot and elementIsBehindRobot) or
        (doorIsBehindRobot and (doorXY.x < elementXY.x)) or
        (not doorIsBehindRobot and (elementXY.x < doorXY.x))
    )
end

--[[
 Evaluate the number of objects in a target room using the omnidirectional
 camera.
--]]
function evaluateObjects(nearestDoor)
    local nObjects = 0
    
    for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
        local vColor = v.color.red .. v.color.green .. v.color.blue
        local isObject = (vColor == OBJECT_COLOR.rgb)
        
        if (isObject and elementInTargetRoom(v, nearestDoor)) then
            nObjects = nObjects + 1
        end
    end
    
    return nObjects
end
