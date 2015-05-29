Color = {}

function Color.new(rgbTable, colorName)
    local self = {}
    
    self.colorName = colorName or ""
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

LIGHT_SOURCE_COLOR = Color.new(
    { red = 255, green = 255, blue = 0 },
    "yellow"
)


OBJECT_COLOR = Color.new(
    { red = 0, green = 255, blue = 0 },
    "green"
)

G_ROBOT_COLOR = Color.new(
    { red = 255, green = 255, blue = 255 },
    "white"
)

L_ROBOT_COLOR = Color.new(
    { red = 0, green = 255, blue = 255},
    "cyan"
)
