require "src/RobotType"

LIGHT_SOURCE_COLOR = {
    colorName = "yellow",
    rgb = "2552550"
}

OBJECT_COLOR = {
    colorName = "green",
    rgb = "02550"
}

--[[
 List of colors which are assigned for elements which are not doors (i.e. green
 for objects, white and cyan for robots, yellow for light sources). Use the rgb
 representation of the colors as keys to easily be able to verify if a color
 exists in this table by directly using the values from the omnidirectional
 camera.
--]]
NOT_DOORS_COLORS = {
    [LIGHT_SOURCE_COLOR.rgb] = LIGHT_SOURCE_COLOR.colorName,
    [OBJECT_COLOR.rgb] = OBJECT_COLOR.colorName,
    [G_ROBOT_COLOR.rgb] = G_ROBOT_COLOR.colorName,
    [L_ROBOT_COLOR.rgb] = L_ROBOT_COLOR.colorName
}

--[[
 Detects rooms by using the omnidirectional camera.
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

--[[
 Retrieves information about the nearest door (i.e. distance, angle, color).
 If the robot knows it is in a target room, it can call this function to
 identify the room.
--]]
function getNearestDoor()
    local nearestDoor
    
    for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
        local vColor = v.color.red .. v.color.green .. v.color.blue
        local isDoor = (NOT_DOORS_COLORS[vColor] == nil)
        
        if isDoor then
            if (nearestDoor == nil) or (v.distance < nearestDoor.distance) then
                nearestDoor = v
            end
        end
    end
    
    return nearestDoor
end

--[[
 Retrieves information about the nearest element of the specificied type. The
 type of an object is identified by its color.
--]]
function getNearestElement(rgbElementColor)
    local nearestElement
    
    for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
        local vColor = v.color.red .. v.color.green .. v.color.blue
        
        if (rgbElementColor == vColor) then
            if (nearestElement == nil)
                or (v.distance < nearestElement.distance)
            then
                nearestDoor = v
            end
        end
    end
    
    return nearestDoor
end

--[[
 Retrieves information about a specific door (i.e. distance, angle, color).
 Returns nil if the door was not seen by the camera.
]]
function getDoor(rgbRoomColor)
    local door
    
    for _,v in ipairs(robot.colored_blob_omnidirectional_camera) do
        local vColor = v.color.red .. v.color.green .. v.color.blue
        local isSoughtDoor = (vColor == rgbRoomColor)
        
        if isSoughtDoor then
            return v
        end
    end
    
    return nil
end
