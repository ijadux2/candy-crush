local Board = require("board")
local Candy = require("candy")

local board
local tileSize = 64
local boardOffsetX = 50
local boardOffsetY = 140
local font

-- Pop-up message system
local popupMessage = {
	active = false,
	title = "",
	message = "",
	timer = 0,
	alpha = 0,
}

-- Level history
local levelHistory = {}

-- Visual effects system
local effects = {
	screenShake = { x = 0, y = 0, intensity = 0, decay = 0.9 },
	glow = { active = false, timer = 0, alpha = 0 },
	vignette = { opacity = 0, radius = 0.8 },
}

-- Utility functions inspired by awesome-love2d libraries
local utils = {
	lerp = function(a, b, t)
		return a + (b - a) * t
	end,

	clamp = function(value, min, max)
		return math.min(math.max(value, min), max)
	end,

	rgbToHsv = function(r, g, b)
		r, g, b = r / 255, g / 255, b / 255
		local max, min = math.max(r, g, b), math.min(r, g, b)
		local h, s, v

		v = max

		if max == 0 then
			h, s = 0, 0
		elseif min == 1 then
			h, s = 0, 0
		else
			local d = max - min
			s = max == 0 and 0 or d / max

			if max == r then
				h = (g - b) / d + (g < b and 3 or 0)
			elseif max == g then
				h = (b - r) / d + 1
			else
				h = (r - g) / d + 2
			end
			h = h / 3
		end

		return h, s, v
	end,

	hsvToRgb = function(h, s, v)
		local r, g, b

		local i = math.floor(h * 6)
		local f = h * 6 - i
		local p = v * (1 - s)
		local q = v * (1 - f * s)
		local t = v * (1 - (1 - f) * s)

		i = i % 6

		if i == 0 then
			r, g, b = v, t, p
		elseif i == 1 then
			r, g, b = q, v, p
		elseif i == 2 then
			r, g, b = p, v, t
		elseif i == 3 then
			r, g, b = p, q, v
		elseif i == 4 then
			r, g, b = t, p, v
		else
			r, g, b = v, p, q
		end

		return r * 255, g * 255, b * 255
	end,

	easeOutQuad = function(t)
		return t * (2 - t)
	end,

	easeInQuad = function(t)
		return t * t
	end,
}

-- Catppuccin Mocha theme colors
local theme = {
	background = { 30 / 255, 30 / 255, 46 / 255 }, -- Base
	surface = { 24 / 255, 24 / 255, 37 / 255 }, -- Mantle
	surface0 = { 49 / 255, 50 / 255, 68 / 255 }, -- Surface0
	surface1 = { 69 / 255, 71 / 255, 90 / 255 }, -- Surface1
	text = { 205 / 255, 214 / 255, 244 / 255 }, -- Text
	subtext = { 147 / 255, 153 / 255, 178 / 255 }, -- Subtext
	accent = { 243 / 255, 139 / 255, 168 / 255 }, -- Pink
	yellow = { 250 / 255, 179 / 255, 135 / 255 }, -- Yellow
	green = { 166 / 255, 227 / 255, 161 / 255 }, -- Green
	blue = { 137 / 255, 180 / 255, 250 / 255 }, -- Blue
	mauve = { 183 / 255, 189 / 255, 248 / 255 }, -- Mauve
}

function love.load()
	love.window.setTitle("Candy Crush")
	love.window.setMode(850, 750)

	-- Enable better font rendering
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- Try to load JetBrains Mono Nerd Font with larger size
	local fontPaths = {
		"/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf",
		"/usr/share/fonts/JetBrainsMonoNerdFont-Regular.ttf",
		"/usr/share/fonts/TTF/JetBrains Mono Nerd Font Complete.ttf",
		"/usr/share/fonts/TTF/JetBrainsMonoNerdFontMono-Regular.ttf",
		"/usr/share/fonts/TTF/FiraCodeNerdFont-Regular.ttf",
		"/usr/share/fonts/TTF/HackNerdFont-Regular.ttf",
		"/System/Library/Fonts/Monaco.ttf",
		"fonts/JetBrainsMonoNerdFont-Regular.ttf",
	}

	font = love.graphics.getFont()
	for _, path in ipairs(fontPaths) do
		local success, loadedFont = pcall(love.graphics.newFont, path, 18)
		if success then
			font = loadedFont
			print("Loaded font: " .. path)
			break
		end
	end

	-- Try different font sizes if JetBrains fails
	if font == love.graphics.getFont() then
		local sizes = { 20, 16, 14 }
		for _, path in ipairs(fontPaths) do
			for _, size in ipairs(sizes) do
				local success, loadedFont = pcall(love.graphics.newFont, path, size)
				if success then
					font = loadedFont
					print("Loaded font: " .. path .. " at " .. size .. "px")
					break
				end
			end
			if font ~= love.graphics.getFont() then
				break
			end
		end
	end

	love.graphics.setFont(font)

	board = Board:new(8, 8)
	board:initialize()

	-- Make functions globally accessible to board
	_G.showPopupMessage = showPopupMessage
	_G.levelHistory = levelHistory
end

function drawUIPanel()
	-- Main UI Panel - increased height for larger fonts
	love.graphics.setColor(theme.surface)
	love.graphics.rectangle("fill", 20, 15, 760, 110, 10)

	-- Border
	love.graphics.setColor(theme.surface1)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", 20, 15, 760, 110, 10)
	love.graphics.setLineWidth(1)

	-- Title with level up animation - larger font
	if board.levelUpAnimation > 0 then
		love.graphics.setColor(theme.yellow)
		local scale = 1 + math.sin(board.levelUpAnimation * math.pi) * 0.3
		love.graphics.printf("󰮯 LEVEL UP!", 0, 22, 850, "center")
	else
		love.graphics.setColor(theme.mauve)
		love.graphics.printf("󰮯 CANDY CRUSH", 0, 22, 850, "center")
	end

	-- Level indicator with glow effect - adjusted spacing
	if board.levelUpAnimation > 0 then
		love.graphics.setColor(theme.yellow)
	else
		love.graphics.setColor(theme.accent)
	end
	love.graphics.printf("󰐮 Level " .. board.level, 40, 60, 160, "left")

	-- Score with progress bar - repositioned for larger font
	love.graphics.setColor(theme.text)
	love.graphics.printf("󰅭 Score", 220, 55, 90, "left")
	love.graphics.printf(board.score .. " / " .. board.targetScore, 220, 75, 160, "left")

	-- Score progress bar - moved down
	local scoreProgress = math.min(1, board.score / board.targetScore)
	love.graphics.setColor(theme.surface0)
	love.graphics.rectangle("fill", 310, 78, 100, 8, 4)
	love.graphics.setColor(theme.green)
	love.graphics.rectangle("fill", 310, 78, 100 * scoreProgress, 8, 4)

	-- Moves with progress bar - repositioned
	love.graphics.setColor(theme.text)
	love.graphics.printf("󰑯 Moves", 460, 55, 90, "left")
	love.graphics.printf(board.moves .. " / " .. board.maxMoves, 460, 75, 100, "left")

	-- Moves progress bar with warning color - moved down
	local movesProgress = math.max(0, 1 - board.moves / board.maxMoves)
	love.graphics.setColor(theme.surface0)
	love.graphics.rectangle("fill", 540, 78, 80, 8, 4)
	if movesProgress > 0.3 then
		love.graphics.setColor(theme.blue)
	else
		love.graphics.setColor(theme.yellow)
	end
	love.graphics.rectangle("fill", 540, 78, 80 * movesProgress, 8, 4)

	-- Target indicator - repositioned
	love.graphics.setColor(theme.yellow)
	love.graphics.printf("󰎝 Target", 650, 55, 90, "left")
	love.graphics.printf(board.targetScore, 650, 75, 100, "left")
end

function drawSidePanel()
	-- Side panel background - increased width for larger fonts
	love.graphics.setColor(theme.surface)
	love.graphics.rectangle("fill", 620, 140, 180, 480, 10)

	-- Border
	love.graphics.setColor(theme.surface1)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", 620, 140, 180, 480, 10)
	love.graphics.setLineWidth(1)

	-- Title
	love.graphics.setColor(theme.mauve)
	love.graphics.printf("󰔚 Levels", 620, 155, 180, "center")

	-- Current level highlight - increased spacing
	love.graphics.setColor(theme.accent)
	love.graphics.rectangle("fill", 630, 185 + (board.level - 1) * 40, 160, 35, 5)
	love.graphics.setColor(theme.text)
	love.graphics.printf("󰐮 " .. board.level, 640, 190 + (board.level - 1) * 40, 140, "left")
	love.graphics.printf("Current", 640, 208 + (board.level - 1) * 40, 140, "left")

	-- Level progression (show next 5 levels) - increased spacing
	for i = 1, 5 do
		local levelNum = board.level + i
		if levelNum <= 20 then -- Show up to level 20
			local y = 185 + (board.level - 1 + i) * 40

			love.graphics.setColor(theme.subtext)
			love.graphics.printf("󰐯 " .. levelNum, 640, y, 140, "left")

			-- Show target score for each level
			local target = levelNum * 1000
			love.graphics.printf("Tgt: " .. target, 640, y + 18, 140, "left")
		end
	end

	-- Stats section - adjusted positioning
	love.graphics.setColor(theme.mauve)
	love.graphics.printf("󰔧 Stats", 620, 420, 180, "center")

	love.graphics.setColor(theme.text)
	love.graphics.printf("Candies: " .. board.candyTypes, 630, 450, 160, "left")
	love.graphics.printf("Moves: " .. board.maxMoves, 630, 475, 160, "left")
	love.graphics.printf("Difficulty: " .. math.floor(board.level / 3 + 1), 630, 500, 160, "left")

	-- Level history - adjusted spacing
	if #levelHistory > 0 then
		love.graphics.setColor(theme.mauve)
		love.graphics.printf("󰔖 History", 620, 540, 180, "center")

		love.graphics.setColor(theme.subtext)
		for i = math.max(1, #levelHistory - 2), #levelHistory do
			local history = levelHistory[i]
			love.graphics.printf(
				"L" .. history.level .. ": " .. history.score,
				630,
				560 + (i - math.max(1, #levelHistory - 2)) * 22,
				160,
				"left"
			)
		end
	end
end

function drawPopupMessage()
	if popupMessage.active then
		-- Semi-transparent overlay
		love.graphics.setColor(0, 0, 0, 0.7 * popupMessage.alpha)
		love.graphics.rectangle("fill", 0, 0, 850, 750)

		-- Pop-up panel - increased size for larger fonts
		local panelWidth = 450
		local panelHeight = 250
		local panelX = (850 - panelWidth) / 2
		local panelY = (750 - panelHeight) / 2

		love.graphics.setColor(theme.surface[1], theme.surface[2], theme.surface[3], popupMessage.alpha)
		love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight, 15)

		-- Border
		love.graphics.setColor(theme.accent[1], theme.accent[2], theme.accent[3], popupMessage.alpha)
		love.graphics.setLineWidth(3)
		love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight, 15)
		love.graphics.setLineWidth(1)

		-- Title - larger font area
		love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], popupMessage.alpha)
		love.graphics.printf(popupMessage.title, panelX, panelY + 35, panelWidth, "center")

		-- Message - increased spacing for larger text
		love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3], popupMessage.alpha)
		love.graphics.printf(popupMessage.message, panelX + 30, panelY + 85, panelWidth - 60, "center")

		-- Continue prompt
		love.graphics.setColor(theme.subtext[1], theme.subtext[2], theme.subtext[3], popupMessage.alpha)
		love.graphics.printf("Click to continue...", panelX, panelY + 200, panelWidth, "center")
	end
end

function showPopupMessage(title, message)
	popupMessage.active = true
	popupMessage.title = title
	popupMessage.message = message
	popupMessage.timer = 3
	popupMessage.alpha = 0
end

function love.draw()
	love.graphics.clear(theme.background)

	-- Apply screen shake
	love.graphics.push()
	love.graphics.translate(effects.screenShake.x, effects.screenShake.y)

	-- Main game rendering
	drawUIPanel()
	board:draw(boardOffsetX, boardOffsetY, tileSize)
	drawSidePanel()
	drawPopupMessage()

	love.graphics.pop()

	-- Apply post-processing effects
	applyPostProcessing()
end

function love.mousepressed(x, y, button)
	if button == 1 then
		-- Handle popup click
		if popupMessage.active then
			popupMessage.active = false
			return
		end

		local gridX = math.floor((x - boardOffsetX) / tileSize) + 1
		local gridY = math.floor((y - boardOffsetY) / tileSize) + 1

		if gridX >= 1 and gridX <= board.width and gridY >= 1 and gridY <= board.height then
			board:selectTile(gridX, gridY)
		end
	end
end

function love.update(dt)
	board:update(dt)

	-- Update visual effects
	updateEffects(dt)

	-- Update popup message
	if popupMessage.active then
		popupMessage.timer = popupMessage.timer - dt

		-- Fade in
		if popupMessage.alpha < 1 then
			popupMessage.alpha = math.min(1, popupMessage.alpha + dt * 3)
		end

		-- Auto-hide after timer expires
		if popupMessage.timer <= 0 then
			popupMessage.alpha = math.max(0, popupMessage.alpha - dt * 3)
			if popupMessage.alpha <= 0 then
				popupMessage.active = false
			end
		end
	end
end

function updateEffects(dt)
	-- Update screen shake
	if effects.screenShake.intensity > 0.01 then
		effects.screenShake.x = math.random(-effects.screenShake.intensity, effects.screenShake.intensity)
		effects.screenShake.y = math.random(-effects.screenShake.intensity, effects.screenShake.intensity)
		effects.screenShake.intensity = effects.screenShake.intensity * effects.screenShake.decay
	else
		effects.screenShake.x = 0
		effects.screenShake.y = 0
	end

	-- Update glow effect
	if effects.glow.active then
		effects.glow.timer = effects.glow.timer - dt
		effects.glow.alpha = math.max(0, effects.glow.timer * 2)
		if effects.glow.timer <= 0 then
			effects.glow.active = false
			effects.glow.alpha = 0
		end
	end
end

function addScreenShake(intensity)
	effects.screenShake.intensity = math.max(effects.screenShake.intensity, intensity)
end

function addGlowEffect()
	effects.glow.active = true
	effects.glow.timer = 0.5
	effects.glow.alpha = 1
end

function applyPostProcessing()
	-- Simple glow effect only
	love.graphics.setBlendMode("alpha")

	-- Apply glow effect
	if effects.glow.active and effects.glow.alpha > 0 then
		love.graphics.setColor(255, 255, 200, effects.glow.alpha * 20)
		love.graphics.rectangle("fill", 0, 0, 850, 750)
	end

	-- Vignette effect removed - now clean display
end
