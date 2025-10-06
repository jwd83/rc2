-- Life Force inspired shoot 'em up game for LÖVE2D
-- Main game loop and initialization

-- Import game modules
local starfield = require('starfield')
local player = require('player')
local bullet = require('bullet')
local enemy = require('enemy')

-- Game state
local gameState = {
    score1 = 0,
    score2 = 0,
    lives = 3,
    gameOver = false,
    restartTimer = 0
}

local screenWidth, screenHeight

function love.load()
    -- Get screen dimensions
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    
    -- Set window title
    love.window.setTitle("Life Force Clone - Shmup Prototype")
    
    -- Initialize game systems
    starfield.init(screenWidth, screenHeight)
    player.init(screenWidth, screenHeight)
    bullet.init()
    enemy.init(screenWidth, screenHeight)
    
    -- Set default font
    love.graphics.setFont(love.graphics.newFont(16))
end

function love.update(dt)
    if gameState.gameOver then
        -- Handle game over state
        gameState.restartTimer = gameState.restartTimer + dt
        if gameState.restartTimer > 3 then
            -- Restart game after 3 seconds
            restartGame()
        end
        return
    end
    
    -- Update all game systems
    starfield.update(dt)
    player.update(dt)
    bullet.update(dt, screenWidth, screenHeight)
    enemy.update(dt)
    
    -- Handle input
    handleInput()
    
    -- Check collisions
    checkCollisions()
    
    -- Spawn enemies
    enemy.spawn(dt)
end

function love.draw()
    -- Clear screen to black
    love.graphics.clear(0, 0, 0, 1)
    
    -- Draw game elements in order
    starfield.draw()
    player.draw()
    bullet.draw()
    enemy.draw()
    
    -- Draw UI
    drawUI()
    
    if gameState.gameOver then
        drawGameOver()
    end
end

function handleInput()
    -- Player 1 controls (arrow keys + right control)
    local p1 = player.getPlayer(1)
    if p1 and not p1.destroyed then
        if love.keyboard.isDown("up") then
            player.movePlayer(1, 0, -1)
        end
        if love.keyboard.isDown("down") then
            player.movePlayer(1, 0, 1)
        end
        if love.keyboard.isDown("left") then
            player.movePlayer(1, -1, 0)
        end
        if love.keyboard.isDown("right") then
            player.movePlayer(1, 1, 0)
        end
        if love.keyboard.isDown("rctrl") then
            if player.canShoot(1) then
                local x, y = player.getPlayerPosition(1)
                bullet.createBullet(x, y - 10, 1)
                player.resetShootTimer(1)
            end
        end
    end
    
    -- Player 2 controls (WASD + spacebar)
    local p2 = player.getPlayer(2)
    if p2 and not p2.destroyed then
        if love.keyboard.isDown("w") then
            player.movePlayer(2, 0, -1)
        end
        if love.keyboard.isDown("s") then
            player.movePlayer(2, 0, 1)
        end
        if love.keyboard.isDown("a") then
            player.movePlayer(2, -1, 0)
        end
        if love.keyboard.isDown("d") then
            player.movePlayer(2, 1, 0)
        end
        if love.keyboard.isDown("space") then
            if player.canShoot(2) then
                local x, y = player.getPlayerPosition(2)
                bullet.createBullet(x, y - 10, 2)
                player.resetShootTimer(2)
            end
        end
    end
end

function checkCollisions()
    -- Get bullets and enemies
    local bullets = bullet.getBullets()
    local enemies = enemy.getEnemies()
    local players = {player.getPlayer(1), player.getPlayer(2)}
    
    -- Check bullet-enemy collisions
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        for j = #enemies, 1, -1 do
            local e = enemies[j]
            if checkCollision(b.x, b.y, 4, 4, e.x, e.y, e.width, e.height) then
                -- Award points to the player who shot the bullet
                if b.player == 1 then
                    gameState.score1 = gameState.score1 + 10
                else
                    gameState.score2 = gameState.score2 + 10
                end
                
                -- Remove bullet and enemy
                table.remove(bullets, i)
                table.remove(enemies, j)
                break
            end
        end
    end
    
    -- Check player-enemy collisions
    for i, p in ipairs(players) do
        if p and not p.destroyed then
            for j = #enemies, 1, -1 do
                local e = enemies[j]
                if checkCollision(p.x, p.y, 20, 20, e.x, e.y, e.width, e.height) then
                    -- Player hit - lose a life
                    gameState.lives = gameState.lives - 1
                    p.destroyed = true
                    
                    -- Remove the enemy
                    table.remove(enemies, j)
                    
                    -- Check game over
                    if gameState.lives <= 0 then
                        gameState.gameOver = true
                        gameState.restartTimer = 0
                    else
                        -- Respawn player after a delay
                        player.respawnPlayer(i, 2.0)
                    end
                    break
                end
            end
        end
    end
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function drawUI()
    -- Set color to white for text
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Draw scores
    love.graphics.print("P1 Score: " .. gameState.score1, 10, 10)
    love.graphics.print("P2 Score: " .. gameState.score2, 10, 30)
    
    -- Draw lives
    love.graphics.print("Lives: " .. gameState.lives, screenWidth - 100, 10)
    
    -- Draw controls (small text)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("P1: Arrows + RCtrl", screenWidth - 200, screenHeight - 40)
    love.graphics.print("P2: WASD + Space", screenWidth - 200, screenHeight - 20)
    love.graphics.setFont(love.graphics.newFont(16))
end

function drawGameOver()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- Game over text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(32))
    local gameOverText = "GAME OVER"
    local textWidth = love.graphics.getFont():getWidth(gameOverText)
    love.graphics.print(gameOverText, screenWidth/2 - textWidth/2, screenHeight/2 - 50)
    
    love.graphics.setFont(love.graphics.newFont(16))
    local finalScoreText = "Final Scores - P1: " .. gameState.score1 .. "  P2: " .. gameState.score2
    local scoreWidth = love.graphics.getFont():getWidth(finalScoreText)
    love.graphics.print(finalScoreText, screenWidth/2 - scoreWidth/2, screenHeight/2)
    
    local restartText = "Restarting in " .. math.ceil(3 - gameState.restartTimer) .. "..."
    local restartWidth = love.graphics.getFont():getWidth(restartText)
    love.graphics.print(restartText, screenWidth/2 - restartWidth/2, screenHeight/2 + 30)
end

function restartGame()
    -- Reset game state
    gameState.score1 = 0
    gameState.score2 = 0
    gameState.lives = 3
    gameState.gameOver = false
    gameState.restartTimer = 0
    
    -- Reinitialize game systems
    player.init(screenWidth, screenHeight)
    bullet.init()
    enemy.init(screenWidth, screenHeight)
end