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
            x = love.math.random(20, screenWidth - 40),
            y = -20, -- Start above screen
            width = love.math.random(15, 30),
            height = love.math.random(15, 30),
            speedX = 0,
            speedY = love.math.random(50, 120),
            color = color,
            type = enemyType
        }
        
        -- Set movement pattern based on type
        if enemyType == 1 then
            -- Straight down
            newEnemy.speedX = 0
        elseif enemyType == 2 then
            -- Diagonal movement
            newEnemy.speedX = love.math.random(-50, 50)
        else
            -- Sinusoidal movement
            newEnemy.speedX = 0
            newEnemy.sineOffset = love.math.random() * math.pi * 2
            newEnemy.sineAmplitude = love.math.random(30, 60)
            newEnemy.sineFrequency = love.math.random(1, 3)
            newEnemy.originalX = newEnemy.x
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
            e.y = e.y + e.speedY * dt
            e.x = e.originalX + math.sin(gameTime * e.sineFrequency + e.sineOffset) * e.sineAmplitude
        else
            -- Regular movement
            e.x = e.x + e.speedX * dt
            e.y = e.y + e.speedY * dt
        end
        
        -- Keep enemies within horizontal bounds for sideways movement
        if e.x < 0 then
            e.x = 0
            e.speedX = math.abs(e.speedX) -- Bounce off left edge
        elseif e.x + e.width > screenWidth then
            e.x = screenWidth - e.width
            e.speedX = -math.abs(e.speedX) -- Bounce off right edge
        end
        
        -- Remove enemies that have gone off screen
        if e.y > screenHeight + 50 then
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