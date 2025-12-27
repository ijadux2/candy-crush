local Candy = require('candy')

local Board = {}
Board.__index = Board

function Board:new(width, height)
    local self = setmetatable({}, Board)
    self.width = width
    self.height = height
    self.grid = {}
    self.selectedTile = nil
    self.score = 0
    self.moves = 0
    self.isAnimating = false
    
    -- Difficulty parameters
    self.level = 1
    self.candyTypes = 6
    self.targetScore = 1000
    self.maxMoves = 50
    self.levelUpAnimation = 0
    
    return self
end

function Board:initialize()
    for y = 1, self.height do
        self.grid[y] = {}
        for x = 1, self.width do
            local candyType
            repeat
                candyType = math.random(1, self.candyTypes)
            until not self:wouldCreateMatch(x, y, candyType)
            
            self.grid[y][x] = Candy:new(x, y, candyType)
        end
    end
end

function Board:wouldCreateMatch(x, y, candyType)
    -- Check horizontal
    if x >= 3 then
        if self.grid[y][x-1].type == candyType and self.grid[y][x-2].type == candyType then
            return true
        end
    end
    
    -- Check vertical
    if y >= 3 then
        if self.grid[y-1][x].type == candyType and self.grid[y-2][x].type == candyType then
            return true
        end
    end
    
    return false
end

function Board:draw(offsetX, offsetY, tileSize)
    for y = 1, self.height do
        for x = 1, self.width do
            local candy = self.grid[y][x]
            if candy then
                local drawX = offsetX + (x - 1) * tileSize
                local drawY = offsetY + (y - 1) * tileSize
                
                candy:draw(drawX, drawY, tileSize)
                
                if self.selectedTile and self.selectedTile.x == x and self.selectedTile.y == y then
                    love.graphics.setColor(250/255, 179/255, 135/255, 0.8) -- Catppuccin Yellow
                    love.graphics.setLineWidth(3)
                    love.graphics.rectangle("line", drawX, drawY, tileSize, tileSize)
                    love.graphics.setLineWidth(1)
                end
            end
        end
    end
end

function Board:selectTile(x, y)
    if self.isAnimating then return end
    
    if not self.selectedTile then
        self.selectedTile = {x = x, y = y}
    else
        local prevX, prevY = self.selectedTile.x, self.selectedTile.y
        
        if (math.abs(x - prevX) == 1 and y == prevY) or (math.abs(y - prevY) == 1 and x == prevX) then
            self:swapTiles(prevX, prevY, x, y)
            self.moves = self.moves + 1
        end
        
        self.selectedTile = nil
    end
end

function Board:swapTiles(x1, y1, x2, y2)
    local temp = self.grid[y1][x1]
    self.grid[y1][x1] = self.grid[y2][x2]
    self.grid[y2][x2] = temp
    
    self.grid[y1][x1].x = x1
    self.grid[y1][x1].y = y1
    self.grid[y2][x2].x = x2
    self.grid[y2][x2].y = y2
    
    local matches = self:findMatches()
    if #matches == 0 then
        -- Swap back
        local temp = self.grid[y1][x1]
        self.grid[y1][x1] = self.grid[y2][x2]
        self.grid[y2][x2] = temp
        
        self.grid[y1][x1].x = x1
        self.grid[y1][x1].y = y1
        self.grid[y2][x2].x = x2
        self.grid[y2][x2].y = y2
    else
        self:processMatches(matches)
    end
end

function Board:findMatches()
    local matches = {}
    
    -- Check horizontal matches
    for y = 1, self.height do
        for x = 1, self.width - 2 do
            if self.grid[y][x] and self.grid[y][x + 1] and self.grid[y][x + 2] then
                if self.grid[y][x].type == self.grid[y][x + 1].type and 
                   self.grid[y][x].type == self.grid[y][x + 2].type then
                    local match = {x = x, y = y, type = 'horizontal', length = 3}
                    
                    -- Check for longer matches
                    local extendX = x + 3
                    while extendX <= self.width and self.grid[y][extendX] and 
                          self.grid[y][extendX].type == self.grid[y][x].type do
                        match.length = match.length + 1
                        extendX = extendX + 1
                    end
                    
                    table.insert(matches, match)
                end
            end
        end
    end
    
    -- Check vertical matches
    for x = 1, self.width do
        for y = 1, self.height - 2 do
            if self.grid[y][x] and self.grid[y + 1][x] and self.grid[y + 2][x] then
                if self.grid[y][x].type == self.grid[y + 1][x].type and 
                   self.grid[y][x].type == self.grid[y + 2][x].type then
                    local match = {x = x, y = y, type = 'vertical', length = 3}
                    
                    -- Check for longer matches
                    local extendY = y + 3
                    while extendY <= self.height and self.grid[extendY][x] and 
                          self.grid[extendY][x].type == self.grid[y][x].type do
                        match.length = match.length + 1
                        extendY = extendY + 1
                    end
                    
                    table.insert(matches, match)
                end
            end
        end
    end
    
    return matches
end

function Board:processMatches(matches)
    self.isAnimating = true
    
    -- Add screen shake for big matches
    if _G.addScreenShake then
        local totalCandies = 0
        for _, match in ipairs(matches) do
            totalCandies = totalCandies + match.length
        end
        local shakeIntensity = math.min(8, totalCandies * 0.5)
        _G.addScreenShake(shakeIntensity)
    end
    
    -- Remove matched candies
    for _, match in ipairs(matches) do
        -- Calculate dynamic score based on difficulty and match length
        local baseScore = 10
        local difficultyMultiplier = 1 + (self.level * 0.2)
        local lengthBonus = (match.length - 3) * 5
        local totalScore = math.floor((baseScore + lengthBonus) * difficultyMultiplier)
        
        if match.type == 'horizontal' then
            for i = 0, match.length - 1 do
                self.grid[match.y][match.x + i] = nil
                self.score = self.score + totalScore
            end
        else -- vertical
            for i = 0, match.length - 1 do
                self.grid[match.y + i][match.x] = nil
                self.score = self.score + totalScore
            end
        end
    end
    
    -- Drop candies and fill empty spaces
    self:dropCandies()
    self:fillEmptySpaces()
    
    -- Check for new matches
    local newMatches = self:findMatches()
    if #newMatches > 0 then
        self:processMatches(newMatches)
    else
        self.isAnimating = false
    end
end

function Board:dropCandies()
    for x = 1, self.width do
        local emptySpaces = 0
        
        for y = self.height, 1, -1 do
            if not self.grid[y][x] then
                emptySpaces = emptySpaces + 1
            elseif emptySpaces > 0 then
                self.grid[y + emptySpaces][x] = self.grid[y][x]
                self.grid[y + emptySpaces][x].y = y + emptySpaces
                self.grid[y][x] = nil
            end
        end
    end
end

function Board:fillEmptySpaces()
    for y = 1, self.height do
        for x = 1, self.width do
            if not self.grid[y][x] then
                self.grid[y][x] = Candy:new(x, y, math.random(1, self.candyTypes))
            end
        end
    end
end

function Board:checkLevelProgression()
    if self.score >= self.targetScore then
        self:nextLevel()
    elseif self.moves >= self.maxMoves then
        self:gameOver()
    end
end

function Board:nextLevel()
    -- Store level history
    local historyEntry = {
        level = self.level,
        score = self.score,
        moves = self.moves,
        candyTypes = self.candyTypes
    }
    
    -- Trigger level complete popup
    if _G.showPopupMessage then
        local message = string.format(
            "Level %d Complete!\n\nScore: %d\nMoves Used: %d\nCandy Types: %d\n\nGet ready for Level %d!",
            self.level, self.score, self.moves, self.candyTypes, self.level + 1
        )
        _G.showPopupMessage("󰮯 LEVEL COMPLETE!", message)
    end
    
    -- Add visual effects
    if _G.addScreenShake then
        _G.addScreenShake(10)
    end
    if _G.addGlowEffect then
        _G.addGlowEffect()
    end
    
    self.level = self.level + 1
    self.candyTypes = math.max(4, 6 - math.floor(self.level / 2))
    self.targetScore = self.level * 1000
    self.maxMoves = math.max(20, 50 - self.level * 3)
    self.moves = 0
    self.levelUpAnimation = 1.0
    
    -- Add to history
    if _G.levelHistory then
        table.insert(_G.levelHistory, historyEntry)
        -- Keep only last 10 levels
        if #_G.levelHistory > 10 then
            table.remove(_G.levelHistory, 1)
        end
    end
end

function Board:gameOver()
    -- Reset game or show game over screen
    self.level = 1
    self.candyTypes = 6
    self.targetScore = 1000
    self.maxMoves = 50
    self.score = 0
    self.moves = 0
    self:initialize()
end

function Board:update(dt)
    -- Update level up animation
    if self.levelUpAnimation > 0 then
        self.levelUpAnimation = self.levelUpAnimation - dt * 2
        if self.levelUpAnimation < 0 then
            self.levelUpAnimation = 0
        end
    end
    
    self:checkLevelProgression()
end

return Board