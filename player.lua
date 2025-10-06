-- Player module for managing both player ships
-- Player 1: red triangle, Player 2: blue triangle

local player = {}

local players = {}
local screenWidth, screenHeight
local playerSpeed = 200 -- Pixels per second
local shootCooldown = 0.2 -- Seconds between shots

function player.init(width, height)
    screenWidth = width
    screenHeight = height
    
    -- Initialize both players
    players = {
        {
            -- Player 1 (red triangle)
            x = 100,
            y = screenHeight * 0.33,
            color = {1, 0, 0}, -- Red
            destroyed = false,
            respawnTimer = 0,
            shootTimer = 0
        },
        {
            -- Player 2 (blue triangle)
            x = 100,
            y = screenHeight * 0.66,
            color = {0, 0, 1}, -- Blue
            destroyed = false,
            respawnTimer = 0,
            shootTimer = 0
        }
    }
end

function player.update(dt)
    for i, p in ipairs(players) do
        -- Update shoot timer
        if p.shootTimer > 0 then
            p.shootTimer = p.shootTimer - dt
        end
        
        -- Handle respawn timer
        if p.destroyed and p.respawnTimer > 0 then
            p.respawnTimer = p.respawnTimer - dt
            if p.respawnTimer <= 0 then
                p.destroyed = false
                -- Reset position
                if i == 1 then
                    p.x = 100
                    p.y = screenHeight * 0.33
                else
                    p.x = 100
                    p.y = screenHeight * 0.66
                end
            end
        end
    end
end

function player.movePlayer(playerNum, dx, dy)
    local p = players[playerNum]
    if not p or p.destroyed then return end
    
    -- Calculate new position using delta time for smooth movement
    local dt = love.timer.getDelta()
    local newX = p.x + dx * playerSpeed * dt
    local newY = p.y + dy * playerSpeed * dt
    
    -- Keep player within screen bounds (with some padding for the triangle)
    local padding = 10
    newX = math.max(padding, math.min(screenWidth - padding, newX))
    newY = math.max(padding, math.min(screenHeight - padding, newY))
    
    p.x = newX
    p.y = newY
end

function player.canShoot(playerNum)
    local p = players[playerNum]
    if not p or p.destroyed then return false end
    return p.shootTimer <= 0
end

function player.resetShootTimer(playerNum, customCooldown)
    local p = players[playerNum]
    if p then
        p.shootTimer = customCooldown or shootCooldown
    end
end

function player.getPlayerPosition(playerNum)
    local p = players[playerNum]
    if p and not p.destroyed then
        return p.x, p.y
    end
    return nil, nil
end

function player.getPlayer(playerNum)
    return players[playerNum]
end

function player.respawnPlayer(playerNum, delay)
    local p = players[playerNum]
    if p then
        p.respawnTimer = delay
    end
end

function player.draw()
    for i, p in ipairs(players) do
        if not p.destroyed then
            -- Set player color
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], 1)
            
            -- Draw triangle pointing right
            local size = 10
            local vertices = {
                p.x + size, p.y,          -- Right point
                p.x - size, p.y - size,   -- Top left
                p.x - size, p.y + size    -- Bottom left
            }
            love.graphics.polygon("fill", vertices)
        elseif p.respawnTimer > 0 then
            -- Draw flashing respawn indicator
            local flash = math.floor(p.respawnTimer * 10) % 2
            if flash == 0 then
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], 0.5)
                local size = 10
                local vertices = {
                    p.x + size, p.y,
                    p.x - size, p.y - size,
                    p.x - size, p.y + size
                }
                love.graphics.polygon("line", vertices)
            end
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return player