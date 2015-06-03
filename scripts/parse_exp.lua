#!/usr/bin/lua

local nRobots = arg[1]

local avgSteps = 0
local bestRoomChosen = 0
local avgRobotsInChosenRoom = 0

for i=1,10 do
    local conf_file = "conf".. i .. ".txt"
    local result_file = "result".. i .. ".txt"
    
    local cmd = io.popen('grep -o "Best is room number [0-9]" '
        .. conf_file .. ' | cut -f 5 -d " "')
    local bestRoom = tonumber(cmd:read())
    print(bestRoom)
    
    local cmd = io.popen('tail -n 1 ' .. result_file .. ' | cut -f1')
    local timeSteps = tonumber(cmd:read())
    avgSteps = avgSteps + timeSteps
    
    local chosenRoom = {
        id = -1,
        nRobots = 0
    }
    for j=2,5 do
        local cmd = io.popen('tail -n1 ' .. result_file .. ' | cut -f' .. j)
        local room = {
            id = j-2,
            nRobots = tonumber(cmd:read())
        }
        print(room.nRobots)
        
        if (room.nRobots > chosenRoom.nRobots) then
            chosenRoom = room
        end
    end
    
    avgRobotsInChosenRoom = avgRobotsInChosenRoom + (100 * chosenRoom.nRobots / nRobots)
    
    local isBestRoomChosen = (bestRoom == chosenRoom.id)
    if isBestRoomChosen then
        bestRoomChosen = bestRoomChosen + 1
    end
end

local avgSteps = avgSteps/10
local avgRobotsInChosenRoom = avgRobotsInChosenRoom/10

print(avgSteps .. "\t" .. bestRoomChosen .. "/10\t" .. avgRobotsInChosenRoom)
