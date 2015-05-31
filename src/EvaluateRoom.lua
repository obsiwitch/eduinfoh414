require "src/RoomDetection"
require "src/Messages"
require "src/Color"

--[[
 If no improvement has been made to the partial score (ground or light +
 objects) for this number of steps, then we assume the score obtained is the
 correct one.
--]]
local MAX_STEPS_NO_IMPROVEMENT = 25

--[[
 Number of steps during which no improvement has been made to the partial score
 (ground or light + objects).
--]]
local steps

-- partial score
local partialScore

function initEvaluate()
    steps = 0
    partialScore = 0
    
    -- The room is not evaluated yet
    robot.leds.set_all_colors(NOT_EVALUATED.colorName)
end

--[[
 Robots of both types evaluate ther room and share their partial score between
 them. We assume the obtained score is correct if it has not been modified for
 MAX_STEPS_NO_IMPROVEMENT.
--]]
function stepEvaluate(roomColor, robotType)
    -- Local score
    local localPartialScore = evaluatePartial(roomColor, robotType)
    
    -- best received partial score from robots of the same type
    local sharedPartialScore = receivePartialScores(roomColor, robotType)
    
    local newPartialScore = math.max(localPartialScore, sharedPartialScore)
    
    -- keep best partial score
    if (newPartialScore > partialScore) then
        partialScore = math.max(partialScore, newPartialScore)
        
        steps = 0
    else
        steps = steps + 1
    end
    
    -- share best partial score
    shareScore(roomColor, I_BYTE_PARTIAL[robotType], partialScore)
    
    if (steps > MAX_STEPS_NO_IMPROVEMENT) then
        robot.leds.set_all_colors(PARTIALLY_EVALUATED.colorName)
        return true
    end
    
    return false
end

--[[
 Receives partial scores (G and L). Returns the best received scores.
 If a robotType is given in parameter, only return the best partial score for
 this type of robot.
--]]
function receivePartialScores(roomColor, robotType)
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
 Evaluates partially the room depending on the robot type.
 * type G robots: ground
 * type L robots: light + objects
 
 Returns the partial score for the specified type of robot in the [0,255]
 interval.
--]]
function evaluatePartial(roomColor, robotType)
    if (robotType == "G") then
        return convertScoreToByte(evaluateGround())
        
    elseif (robotType == "L") then
        return convertScoreToByte(
            (evaluateLight() + evaluateObjects())/2
        )
    end
end

--[[
 Evaluates the ground color. Returns the highest value retrieved from the
 sensors.
--]]
function evaluateGround()
    local best = 0
    
    for _,v in pairs(robot.motor_ground) do
        best = math.max(best, v.value)
    end
    
    return best
end

--[[
 Evaluates the light of a room by returning the highest value retrieved from
 the sensors.
--]]
function evaluateLight()
    local best = 0
    
    for _,v in pairs(robot.light) do
        best = math.max(best, v.value)
    end
    
    return best
end

--[[
 Evaluates the number of objects in a target room using the omnidirectional
 camera.
 
 There are between 2 and 12 objects per room. With this information, we can
 compute a score in [0,1].
--]]
function evaluateObjects()
    local nObjects = 0
    
    local nearestDoor = getNearestDoor()
    
    for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
        local vColor = Color.new(v.color)
        local isObject = Color.eq(vColor, OBJECT_COLOR)
        
        if (isObject and elementInTargetRoom(v, nearestDoor)) then
            nObjects = nObjects + 1
        end
    end
    
    return nObjects/12
end
