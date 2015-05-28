Color = {}

function Color.new(rgbTable)
    local self = {}
    
    self.red = rgbTable.red
    self.green = rgbTable.green
    self.blue = rgbTable.blue
    self.rgb = rgbTable.red .. rgbTable.green .. rgbTable.blue
    
    return self
end

function Color.eq(lhs, rhs)
    return (lhs.red == rhs.red)
        and (lhs.green == rhs.green)
        and (lhs.blue == rhs.blue)
end
