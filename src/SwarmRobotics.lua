-- TODO clean requires
require "src/Bot"
require "src/Environment"
require "src/MoveIntoRoom"
require "src/TargetRoomFormation"
require "src/EvaluateRoom"
require "src/Gather"
require "src/SynchronizeScores"
require "src/BestRoomFormation"

--[[
 Table listing the different states a robot can enter.
 * START
 * INIT_SPLIT_ROOMS: initializes the MoveIntoRoom state machine with the nearest
 room
 * SPLIT_ROOMS: move into the nearest room
 * ROOM_FORMATION: group robots inside rooms between the light source and the
 door, and partially evaluate the room
 * GATHER_SYNC: gather robots that have already evaluated their room, and share
 their score. Go towards the best room once it has been found.
 * BEST: move inside the best room
--]]
local STATES = {
    START = 0,
    INIT_SPLIT_ROOMS = 1,
    SPLIT_ROOMS = 2,
    ROOM_FORMATION = 3,
    GATHER_SYNC = 4,
    BEST = 5
}

-- current state
local state

--[[
 Initializes state machine & robot's variables.
--]]
function init()
    Bot.init()
    
    state = STATES.START
end

--[[
 State machine executed at each time step.
 @see STATES
--]]
function step()
    if (state == STATES.START) then
        -- Wait one time step before starting. This is done in order to avoid a
        -- problem with the camera (returned distances during the first time
        -- step are not correct).
        state = STATES.INIT_SPLIT_ROOMS
        
    elseif (state == STATES.INIT_SPLIT_ROOMS) then
        local nearestRoomColor = MoveIntoRoom.initNearest()
        Bot.roomColor = nearestRoomColor
        state = STATES.SPLIT_ROOMS
        
    elseif (state == STATES.SPLIT_ROOMS) then
        local isInsideRoom = MoveIntoRoom.step()

        if isInsideRoom then
            Evaluate.init()
            state = STATES.ROOM_FORMATION
        end
    
    elseif (state == STATES.ROOM_FORMATION) then
        stepTargetRoomFormation()
        local evalStatus = Evaluate.step(Bot.roomColor)
        
        if evalStatus.finished then
            Gather.init()
            Synchronize.init(evalStatus.partialScore, Bot.roomColor)
            state = STATES.GATHER_SYNC
        end
    
    elseif (state == STATES.GATHER_SYNC) then
        local bestRoomColor = Synchronize.step()
        
        -- Check if all neighbouring robots have totally evaluated their room
        if bestRoomColor ~= nil and Synchronize.checkEvalStatusRobots() then
            if not Color.eq(bestRoomColor, Bot.roomColor) then
                -- new best room found
                Bot.roomColor = bestRoomColor
                MoveIntoRoom.init(bestRoomColor)
            else
                -- go towards best room
                local isInsideRoom = MoveIntoRoom.step()
                
                -- best room attained
                if isInsideRoom then
                    BestRoomFormation.init()
                    state = STATES.BEST
                end
            end
        else
            Gather.step()
        end
    
    elseif (state == STATES.BEST) then
        BestRoomFormation.step()
    end
end

--[[
 Call init() in order to restore the program to its initial state.
--]]
function reset()
    init()
end

--[[
 This function is executed only once, when the robot is removed from the
 simulation.
--]]
function destroy()
end
