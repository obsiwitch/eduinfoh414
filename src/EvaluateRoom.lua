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
 TODO
--]]
function evaluateLight()
    -- TODO
end

--[[
 TODO
--]]
function evaluateObjects()
    -- TODO
end
