local Candy = {}
Candy.__index = Candy

-- Catppuccin Mocha theme colors for candies
local colors = {
    {243/255, 139/255, 168/255},  -- Pink
    {166/255, 227/255, 161/255},  -- Green  
    {137/255, 180/255, 250/255},  -- Blue
    {250/255, 179/255, 135/255},  -- Yellow
    {245/255, 194/255, 231/255},  -- Mauve
    {148/255, 226/255, 213/255}   -- Teal
}

function Candy:new(x, y, type)
    local self = setmetatable({}, Candy)
    self.x = x
    self.y = y
    self.type = type
    self.color = colors[type]
    self.scale = 1.0
    return self
end

function Candy:draw(x, y, size)
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", x + size * 0.1, y + size * 0.1, size * 0.8, size * 0.8, 10)
    
    love.graphics.setColor(self.color[1] * 0.8, self.color[2] * 0.8, self.color[3] * 0.8)
    love.graphics.rectangle("line", x + size * 0.1, y + size * 0.1, size * 0.8, size * 0.8, 10)
    
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", x + size * 0.2, y + size * 0.2, size * 0.3, size * 0.3, 5)
end

return Candy
