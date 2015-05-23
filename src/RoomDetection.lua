--[[
 List of colors which are assigned for elements which are not doors (i.e. green
 for objects, yellow and cyan for robots). Use the rgb representation of the
 colors as keys to easily be able to verify if a color exists in this table
 by directly using the values from the omnidirectional camera.
--]]
NOT_DOORS_COLORS = {
    ["02550"] = "green",
    ["2552550"] = "yellow",
    ["0255255"] = "cyan"
}

--[[
 Detect rooms by using the omnidirectional camera.
--]]
function detectRooms()
    local roomsSet = {}
    
    for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
        local vColor = v.color.red .. v.color.green .. v.color.blue
        local isDoor = (NOT_DOORS_COLORS[vColor] == nil)
        
        if isDoor then
            roomsSet[vColor] = false
        end
    end
    
    return roomsSet
end
