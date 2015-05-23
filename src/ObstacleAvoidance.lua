--[[
 This file holds a step function allowing to do obstacle avoidance. The behavior
 is the one seen in class (1st course exercise, obstacleAvoidance_sta).
--]]

-- Holds whether the robot should avoid obstacles or move forward.
avoidObstacleMode = false

--[[
 Doors are considered obstacles and detected using the distance returned by the
 omnidirectional camera. The fact that the robot turns randomly to escape an
 obstacle implies that the robot can go trough the door. By doing so, the
 robots get stuck in front of the door. This variable is used as an escape
 mechanism: if the new distance from the door is greater than the oldVDistance,
 then it means that the robot is distancing himself from the door. In this case,
 even if the door is near, don't detect it as an obstacle.
--]]
oldVDistance = math.huge

function resetAvoid()
    avoidObstacleMode = false
    oldVDistance = math.huge
end

--[[
 Iterates over the front proximity sensors values. THe table indexes of these
 front sensors are in the intervall [1,4] union [21,24].
--]]
function frontProximityIterator(proximityTable)
    local i = 0
    local n = #proximityTable

    return function()
        i = i + 1

        if i == 5 then
            i = 21
        end

        if i <= n then
            return proximityTable[i]
        end
    end
end

--[[
  Checks the 8 front sensors for an obstacle (sensor value > 0.2).
  Doors are detected and considered obstacles by checking the omnidirectional
  camera.
--]]
function senseObstacle(rooms)
    for prox in frontProximityIterator(robot.proximity) do
    	if (prox.value > 0.2) then
            return true
    	end
    end
    
    for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
        local vColor = v.color.red .. v.color.green .. v.color.blue
        local isDoor = (rooms[vColor] ~= nil)
        
        if (isDoor and v.distance <= 25) then
            -- escape mechanism (see oldVDistance description)
            if (oldVDistance < v.distance) then
                oldVDistance = math.huge
                return false
            end
            
            oldVDistance = v.distance
            log(v.distance)
            return true
        end
    end
    
    return false
end

--[[
 * Sense: sense obstacles
 * Think: if the robot is entering the avoidObstacleMode, compute the number
        of steps during which he will turn (random number in [4,30]) and in which
        direction he will turn (bernoulli distribution). If it's already in
        avoidObstacleMode mode, update the number of steps.
 * Act: if it's not in avoidObstacleMode go forward, else turn right or left
        depending on what was previously computed.
--]]
function stepAvoid(rooms)
	-- Sense
	local obstacle = senseObstacle(rooms)

	-- Think
	if (not avoidObstacleMode) then
		if (obstacle) then
			avoidObstacleMode = true
			turningSteps = robot.random.uniform_int(4,30)
			turningRight = robot.random.bernoulli()
		end
	else
		turningSteps = turningSteps - 1
		if (turningSteps == 0) then
			avoidObstacleMode = false
		end
	end

	-- Act
	if (not avoidObstacleMode) then
		robot.wheels.set_velocity(10,10)
	else
		if (turningRight == 1) then
			robot.wheels.set_velocity(5,-5)
		else
			robot.wheels.set_velocity(-5,5)
		end
	end
	
end
