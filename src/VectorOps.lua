--[[
  This file holds functions related to vector and coordinates systems
  manipulation.
--]]

--[[
 Converts polar coordinates to cartesian coordinates.
--]]
function polarToCartesianCoords(cartesianCoords)
    return {
        x = cartesianCoords.value * math.cos(cartesianCoords.angle),
        y = cartesianCoords.value * math.sin(cartesianCoords.angle)
    }
end

--[[
 Converts cartesian coordinates to polar coordinates.
--]]
function cartesianToPolarCoords(polarCoords)
    return {
        value = math.sqrt(polarCoords.x^2 + polarCoords.y^2),
        angle = math.atan2(polarCoords.y, polarCoords.x)
    }
end

--[[
 Compute the opposite vector from a vector in polar coordinates.
--]]
function computeOppositeVector(polarVector)
    local oppositeAngle
    if (polarVector.angle > 0) then
        oppositeAngle = polarVector.angle - math.pi
    else
        oppositeAngle = polarVector.angle + math.pi
    end
    
    return {
        value = polarVector.value,
        angle = oppositeAngle
    }
end

--[[
 Sum polar vectors head to tail.
 Converts the 2 vectors into cartesian coordinates, sum them and convert them
 back to polar coordinates.
--]]
function headTailSumPolarVectors(vectors)
    local accumulator = { x = 0, y = 0 }
    
    for _,v in ipairs(vectors) do
        local vXY = polarToCartesianCoords(v)
        
        accumulator.x = accumulator.x + vXY.x
        accumulator.y = accumulator.y + vXY.y
    end
    
    return cartesianToPolarCoords(accumulator)
end
