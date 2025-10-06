-- Enemy module for managing randomly spawning colored rectangles
-- Enemies drift downward or sideways depending on the stage type

local enemy = {}

local enemies = {}
local spawnTimer = 0
local spawnRate = 1.5 -- Seconds between spawns (will decrease over time)
local minSpawnRate = 0.5
local spawnRateDecrease = 0.02 -- Decrease spawn rate over time for difficulty
local gameTime = 0
local screenWidth, screenHeight

-- Enemy colors
local enemyColors = {
    {1, 0.5, 0},    -- Orange
    {1, 0, 1},      -- Magenta
    {0, 1, 1},      -- Cyan
    {1, 1, 0},      -- Yellow
    {0.5, 1, 0},    -- Green
    {1, 0.5, 0.5},  -- Pink
}

function enemy.init(width, height)
    screenWidth = width
    screenHeight = height
    enemies = {}
    spawnTimer = 0
    spawnRate = 1.5
    gameTime = 0
end

function enemy.spawn(dt)
    gameTime = gameTime + dt
    spawnTimer = spawnTimer + dt
    
    -- Gradually increase difficulty by reducing spawn rate
    local currentSpawnRate = math.max(minSpawnRate, spawnRate - (gameTime * spawnRateDecrease))
    
    if spawnTimer >= currentSpawnRate then
        spawnTimer = 0
        
        -- Create a new enemy
        local enemyType = love.math.random(1, 3) -- Different movement patterns
        local color = enemyColors[love.math.random(1, #enemyColors)]
        
        local newEnemy = {
            x = screenWidth + 20, -- Start from right side
            y = love.math.random(20, screenHeight - 40),
            width = love.math.random(15, 30),
            height = love.math.random(15, 30),
            speedX = love.math.random(50, 120),
            speedY = 0,
            color = color,
            type = enemyType
        }
        
        -- Set movement pattern based on type
        if enemyType == 1 then
            -- Straight left
            newEnemy.speedY = 0
        elseif enemyType == 2 then
            -- Diagonal movement
            newEnemy.speedY = love.math.random(-50, 50)
        else
            -- Sinusoidal movement
            newEnemy.speedY = 0
            newEnemy.sineOffset = love.math.random() * math.pi * 2
            newEnemy.sineAmplitude = love.math.random(30, 60)
            newEnemy.sineFrequency = love.math.random(1, 3)
            newEnemy.originalY = newEnemy.y
        end
        
        table.insert(enemies, newEnemy)
    end
end

function enemy.update(dt)
    -- Move enemies and remove off-screen ones
    for i = #enemies, 1, -1 do
        local e = enemies[i]
        
        -- Update position based on enemy type
        if e.type == 3 then
            -- Sinusoidal movement
            e.x = e.x - e.speedX * dt
            e.y = e.originalY + math.sin(gameTime * e.sineFrequency + e.sineOffset) * e.sineAmplitude
        else
            -- Regular movement
            e.x = e.x - e.speedX * dt
            e.y = e.y + e.speedY * dt
        end
        
        -- Keep enemies within vertical bounds for vertical movement
        if e.y < 0 then
            e.y = 0
            e.speedY = math.abs(e.speedY) -- Bounce off top edge
        elseif e.y + e.height > screenHeight then
            e.y = screenHeight - e.height
            e.speedY = -math.abs(e.speedY) -- Bounce off bottom edge
        end
        
        -- Remove enemies that have gone off screen to the left
        if e.x + e.width < -50 then
            table.remove(enemies, i)
        end
    end
end

function enemy.draw()
    -- Draw all enemies as colored rectangles
    for i, e in ipairs(enemies) do
        love.graphics.setColor(e.color[1], e.color[2], e.color[3], 1)
        love.graphics.rectangle("fill", e.x, e.y, e.width, e.height)
        
        -- Draw a white border for better visibility
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("line", e.x, e.y, e.width, e.height)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function enemy.getEnemies()
    return enemies
end

return enemy