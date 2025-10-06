-- Particle system for explosion effects
-- Creates colored circles that expand and fade when enemies are destroyed

local particles = {}

local particleList = {}

function particles.init()
    particleList = {}
end

function particles.createExplosion(x, y, color)
    -- Create multiple particles for each explosion
    local numParticles = love.math.random(8, 15)
    
    for i = 1, numParticles do
        local particle = {
            x = x,
            y = y,
            vx = love.math.random(-100, 100), -- Velocity X
            vy = love.math.random(-100, 100), -- Velocity Y
            size = love.math.random(2, 6),
            maxSize = love.math.random(8, 16),
            life = 1.0, -- Life starts at 1.0 and decreases
            maxLife = love.math.random(0.5, 1.5),
            color = {
                color[1] + love.math.random(-0.2, 0.2), -- Vary the color slightly
                color[2] + love.math.random(-0.2, 0.2),
                color[3] + love.math.random(-0.2, 0.2)
            },
            growthRate = love.math.random(10, 25) -- How fast the particle grows
        }
        
        -- Clamp color values
        for j = 1, 3 do
            particle.color[j] = math.max(0, math.min(1, particle.color[j]))
        end
        
        table.insert(particleList, particle)
    end
end

function particles.update(dt)
    -- Update all particles
    for i = #particleList, 1, -1 do
        local p = particleList[i]
        
        -- Update position
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        
        -- Update size (expand over time)
        if p.size < p.maxSize then
            p.size = p.size + p.growthRate * dt
        end
        
        -- Apply friction to velocity
        p.vx = p.vx * 0.98
        p.vy = p.vy * 0.98
        
        -- Decrease life
        p.life = p.life - (dt / p.maxLife)
        
        -- Remove dead particles
        if p.life <= 0 then
            table.remove(particleList, i)
        end
    end
end

function particles.draw()
    -- Draw all particles
    for i, p in ipairs(particleList) do
        -- Set color with alpha based on life
        local alpha = math.max(0, p.life)
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
        
        -- Draw particle as a filled circle
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function particles.getParticleCount()
    return #particleList
end

return particles