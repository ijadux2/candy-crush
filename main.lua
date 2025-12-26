local Board = require('board')
local Candy = require('candy')

local board
local tileSize = 64
local boardOffsetX = 50
local boardOffsetY = 100

-- Catppuccin Mocha theme colors
local theme = {
    background = {30/255, 30/255, 46/255}, -- Base
    surface = {24/255, 24/255, 37/255},   -- Mantle
    text = {205/255, 214/255, 244/255},    -- Text
    accent = {243/255, 139/255, 168/255},  -- Pink
    yellow = {250/255, 179/255, 135/255}   -- Yellow
}

function love.load()
    love.window.setTitle("Candy Crush")
    love.window.setMode(800, 700)
    
    board = Board:new(8, 8)
    board:initialize()
end

function love.draw()
    love.graphics.clear(theme.background)
    
    love.graphics.setColor(theme.text)
    love.graphics.printf("CANDY CRUSH", 0, 20, 800, "center")
    
    love.graphics.setColor(theme.text)
    love.graphics.printf("Score: " .. board.score, 0, 50, 400, "left")
    love.graphics.printf("Moves: " .. board.moves, 400, 50, 400, "right")
    
    board:draw(boardOffsetX, boardOffsetY, tileSize)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local gridX = math.floor((x - boardOffsetX) / tileSize) + 1
        local gridY = math.floor((y - boardOffsetY) / tileSize) + 1
        
        if gridX >= 1 and gridX <= board.width and gridY >= 1 and gridY <= board.height then
            board:selectTile(gridX, gridY)
        end
    end
end

function love.update(dt)
    board:update(dt)
end
