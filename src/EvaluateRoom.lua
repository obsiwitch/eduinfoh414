require "src/RoomDetection"
require "src/Messages"
require "src/Color"

Evaluate = {}

--[[
 Initializes the Evaluate singleton.
--]]
function Evaluate.init()
    --- Constants
    
    --[[
     If no improvement has been made to the partial score (ground or light +
     objects) for this number of steps, then we assume the score obtained is the
     correct one.
    --]]
    local MAX_STEPS_NO_IMPROVEMENT = 25
    
    --- Private attributes
    
    --[[
     Number of steps during which no improvement has been made to the partial score
     (ground or light + objects).
    --]]
    local steps = 0
    
    local partialScore = 0
    
    --- Additional initialization instructions
    
    -- The room is not evaluated yet
    robot.leds.set_all_colors(NOT_EVALUATED.colorName)
    
    --- Public methods

    --[[
     Robots of both types evaluate their room. We assume the obtained score is
     correct if it has not been modified for MAX_STEPS_NO_IMPROVEMENT.
    --]]
    function Evaluate.step(roomColor, robotType)
        -- evaluate partial score
        local newPartialScore = Evaluate.partial(roomColor, robotType)
        
        -- keep best partial score
        if (newPartialScore > partialScore) then
            partialScore = math.max(partialScore, newPartialScore)
            
            steps = 0
        else
            steps = steps + 1
        end
        
        if (steps > MAX_STEPS_NO_IMPROVEMENT) then
            robot.leds.set_all_colors(PARTIALLY_EVALUATED.colorName)
            return {
                finished = true,
                partialScore = partialScore
            }
            
        else
            return {
                finished = false,
                partialScore = partialScore
            }
        end
    end
    
    --[[
     Evaluates partially the room depending on the robot type.
     * type G robots: ground
     * type L robots: light + objects
     
     Returns the partial score for the specified type of robot in the [0,255]
     interval.
    --]]
    function Evaluate.partial(roomColor, robotType)
        if (robotType == "G") then
            return convertScoreToByte(Evaluate.ground())
            
        elseif (robotType == "L") then
            return convertScoreToByte(
                (Evaluate.light() + Evaluate.objects())/2
            )
        end
    end
    
    --[[
     Evaluates the ground color. Returns the highest value retrieved from the
     sensors.
    --]]
    function Evaluate.ground()
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
    function Evaluate.light()
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
    function Evaluate.objects()
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
end
