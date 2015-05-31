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
    
    -- The room is not evaluated yet
    robot.leds.set_all_colors(NOT_EVALUATED.colorName)
    
    state = STATES.EVAL_PARTIAL
end

--[[
 Evolves state machine.
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
        -- room partially evaluated
        robot.leds.set_all_colors(PARTIALLY_EVALUATED.colorName)
        
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
 Receives partial scores (G and L). Returns the best received score.
--]]
function receivePartialScores(roomColor)
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
    
    return best
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
