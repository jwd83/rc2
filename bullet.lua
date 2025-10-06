-- Bullet module for managing player projectiles
-- Player shots are small white circles that travel straight forward

local bullet = {}

local bullets = {}
local bulletSpeed = 400 -- Pixels per second
local bulletRadius = 2

function bullet.init()
    bullets = {}
end

function bullet.createBullet(x, y, player)
    local newBullet = {
        x = x,
        y = y,
        player = player, -- Which player fired this bullet
        radius = bulletRadius
    }
    table.insert(bullets, newBullet)
end

function bullet.update(dt, screenWidth, screenHeight)
    -- Move bullets upward and remove off-screen bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b.y = b.y - bulletSpeed * dt
        
        -- Remove bullets that have gone off screen
        if b.y + b.radius < 0 then
            table.remove(bullets, i)
        end
    end
end

function bullet.draw()
    -- Draw all bullets as white circles
    love.graphics.setColor(1, 1, 1, 1)
    for i, b in ipairs(bullets) do
        love.graphics.circle("fill", b.x, b.y, b.radius)
    end
end

function bullet.getBullets()
    return bullets
end

return bullet