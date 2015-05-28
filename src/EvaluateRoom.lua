require "src/RoomDetection"
require "src/Messages"
require "src/Color"

--[[
 This state machine has for purpose to evaluate a room score and share it with
 other robots in order to obtain the final score.
--]]

--[[
 * EVAL_PARTIAL: robots of both types evaluate ther room and share their partial
 scores between them. The state machine evolves to the next state if the score
 has not been modified for MAX_STEPS_NO_IMPROVEMENT.
 * SUM: sum the partial scores
--]]
local STATES = {
    EVAL_PARTIAL = 0,
    SUM = 1
}

--[[
 If no improvement has been made to the partial scores (ground or light +
 objects) for this number of steps, then we assume the score obtained is the
 correct one.
--]]
local MAX_STEPS_NO_IMPROVEMENT = 25

--[[
 Number of steps during which no improvement has been made to the partial scores
 (ground or light + objects).
--]]
local steps

-- partial scores
local partialScores

-- current state
local state

function initEvaluate()
    steps = 0
    partialScores = {
        L = 0,
        G = 0
    }
    state = STATES.EVAL_PARTIAL
end

--[[
 Evolves state machine.
 
 roomColor should be a table containing the color's 3 separated
 components (red, green, blue) and also a string with the 3 components
 concatenated (rgb) (@see Color)
--]]
function stepEvaluate(roomColor, robotType)
    if (state == STATES.EVAL_PARTIAL) then
        -- Local score
        local localPartialScores = evaluatePartial(roomColor, robotType)
        
        -- shared partial scores
        local sharedPartialScores = receivePartialScores(roomColor)
        
        local newPartialScores = {
            L = math.max(localPartialScores.L, sharedPartialScores.L),
            G = math.max(localPartialScores.G, sharedPartialScores.G)
        }
        
        -- keep best partial scores
        if (newPartialScores.L > partialScores.L) or
           (newPartialScores.G > partialScores.G)
        then
            partialScores.L = math.max(partialScores.L, newPartialScores.L)
            partialScores.G = math.max(partialScores.G, newPartialScores.G)
            
            steps = 0
        else
            steps = steps + 1
        end
        
        -- share best partial scores
        shareScore(roomColor, I_BYTE_PARTIAL.L, partialScores.L)
        shareScore(roomColor, I_BYTE_PARTIAL.G, partialScores.G)
        
        if (steps > MAX_STEPS_NO_IMPROVEMENT)
            and (partialScores.L ~= 0)
            and (partialScores.G ~= 0)
        then
            state = STATES.SUM
        end
        
    elseif (state == STATES.SUM) then
        return {
            finished = true,
            finalScore = (partialScores.L + partialScores.G)/2
        }
    end
    
    return {
        finished = false,
        finalScore = 0
    }
end

--[[
 Evaluates partially the room depending on the robot type.
 * type G robots: ground
 * type L robots: light + objects
 
 Returns a table containing the partial scores for L and G. If the current
 robot is a type G robot, then the L score will be 0, and vice versa. The score
 for the current type of robot is returned in the [0,255] interval.
--]]
function evaluatePartial(roomColor, robotType)
    local partialScores = { G = 0, L = 0}
    
    if (robotType == "G") then
        partialScores.G = convertScoreToByte(evaluateGround())
        
    elseif (robotType == "L") then
        partialScores.L = convertScoreToByte(
            (evaluateLight() + evaluateObjects())/2
        )
    end
    
    return partialScores
end

--[[
 Converts a score in [0,1] to a value in [0,255].
--]]
function convertScoreToByte(score)
    return math.floor(255 * score)
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
 Returns whether the specified element is contained in the target room or not.
 The nearest door is used as a reference to determine the limit of the room.
 
 @note This function will only work as intended in a target room, because this
 type of room only has one door. It will not work if it is used in the central
 room.
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
 Evaluates the number of objects in a target room using the omnidirectional
 camera.
 
 There are between 2 and 12 objects per room. With this information, we can
 compute a score in [0,1].
--]]
function evaluateObjects()
    local nObjects = 0
    
    local nearestDoor = getNearestDoor()
    
    for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
        local vColor = v.color.red .. v.color.green .. v.color.blue
        local isObject = (vColor == OBJECT_COLOR.rgb)
        
        if (isObject and elementInTargetRoom(v, nearestDoor)) then
            nObjects = nObjects + 1
        end
    end
    
    return nObjects/12
end
