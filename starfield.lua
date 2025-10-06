-- Starfield module for parallax scrolling background
-- Creates a continuously scrolling starfield made of white dots

local starfield = {}

local stars = {}
local numStars = 200
local screenWidth, screenHeight

function starfield.init(width, height)
    screenWidth = width
    screenHeight = height
    stars = {}
    
    -- Create stars with random positions, sizes, and speeds
    for i = 1, numStars do
        local star = {
            x = love.math.random() * screenWidth,
            y = love.math.random() * screenHeight,
            size = love.math.random(1, 3),
            speed = love.math.random(20, 100), -- Pixels per second
            brightness = love.math.random(0.3, 1.0) -- For variety in star appearance
        }
        table.insert(stars, star)
    end
end

function starfield.update(dt)
    -- Move all stars left across the screen
    for i, star in ipairs(stars) do
        star.x = star.x - star.speed * dt
        
        -- Reset star position when it goes off screen
        if star.x < -star.size then
            star.x = screenWidth + star.size
            star.y = love.math.random() * screenHeight
            -- Randomize properties when resetting
            star.size = love.math.random(1, 3)
            star.speed = love.math.random(20, 100)
            star.brightness = love.math.random(0.3, 1.0)
        end
    end
end

function starfield.draw()
    -- Draw all stars as white circles
    for i, star in ipairs(stars) do
        love.graphics.setColor(1, 1, 1, star.brightness)
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
    
    -- Reset color to white for other drawing operations
    love.graphics.setColor(1, 1, 1, 1)
end

return starfield