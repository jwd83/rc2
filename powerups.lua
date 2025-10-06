-- Power-up system for the game
-- Spawns collectible power-ups that enhance player abilities

local powerups = {}

local powerupList = {}
local spawnTimer = 0
local spawnRate = 12 -- Spawn every 12 seconds
local screenWidth, screenHeight

-- Power-up types
local POWERUP_TYPES = {
    RATE_UP = {
        name = "Rate Up",
        color = {0, 1, 0}, -- Green
        symbol = "R",
        duration = 10 -- seconds
    },
    DOUBLE_SHOT = {
        name = "Double Shot", 
        color = {1, 0, 1}, -- Magenta
        symbol = "D",
        duration = 8 -- seconds
    }
}

function powerups.init(width, height)
    screenWidth = width
    screenHeight = height
    powerupList = {}
    spawnTimer = 0
end

function powerups.spawn(dt)
    spawnTimer = spawnTimer + dt
    
    if spawnTimer >= spawnRate then
        spawnTimer = 0
        
        -- Random chance to spawn a power-up
        if love.math.random() < 0.7 then -- 70% chance
            local powerupType = love.math.random(1, 2)
            local typeData = powerupType == 1 and POWERUP_TYPES.RATE_UP or POWERUP_TYPES.DOUBLE_SHOT
            
            local newPowerup = {
                x = screenWidth + 20, -- Start from right side
                y = love.math.random(50, screenHeight - 50),
                width = 25,
                height = 25,
                speed = love.math.random(40, 80),
                type = typeData,
                flashTimer = 0,
                collected = false
            }
            
            table.insert(powerupList, newPowerup)
        end
    end
end

function powerups.update(dt)
    -- Update power-ups
    for i = #powerupList, 1, -1 do
        local p = powerupList[i]
        
        -- Move power-up left
        p.x = p.x - p.speed * dt
        
        -- Update flash timer for visual effect
        p.flashTimer = p.flashTimer + dt * 8
        
        -- Remove off-screen power-ups
        if p.x + p.width < -50 then
            table.remove(powerupList, i)
        end
    end
end

function powerups.draw()
    -- Draw all power-ups
    for i, p in ipairs(powerupList) do
        -- Flash effect
        local alpha = 0.7 + 0.3 * math.sin(p.flashTimer)
        love.graphics.setColor(p.type.color[1], p.type.color[2], p.type.color[3], alpha)
        
        -- Draw power-up box
        love.graphics.rectangle("fill", p.x, p.y, p.width, p.height)
        
        -- Draw border
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.rectangle("line", p.x, p.y, p.width, p.height)
        
        -- Draw symbol
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.printf(p.type.symbol, p.x, p.y + 5, p.width, "center")
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
end

function powerups.checkCollisions(players)
    -- Check collisions with players
    for i = #powerupList, 1, -1 do
        local p = powerupList[i]
        
        for playerNum = 1, 2 do
            local player = players[playerNum]
            if player and not player.destroyed then
                -- Simple AABB collision
                if player.x < p.x + p.width and
                   player.x + 20 > p.x and
                   player.y < p.y + p.height and
                   player.y + 20 > p.y then
                    
                    -- Power-up collected!
                    powerups.applyPowerup(playerNum, p.type)
                    table.remove(powerupList, i)
                    break
                end
            end
        end
    end
end

function powerups.applyPowerup(playerNum, powerupType)
    -- Call the main game's power-up application function
    if _G.applyPowerup then
        _G.applyPowerup(playerNum, powerupType)
    end
end

function powerups.getPowerups()
    return powerupList
end

return powerups