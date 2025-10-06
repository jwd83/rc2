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

-- Joystick state
local joysticks = {
    player1 = nil,
    player2 = nil
}

local screenWidth, screenHeight

function love.load()
    -- Set up fullscreen 16:9 display
    love.window.setMode(0, 0, {fullscreen = true})
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    
    -- Set window title
    love.window.setTitle("Life Force Clone - Horizontal Shmup")
    
    -- Initialize game systems
    starfield.init(screenWidth, screenHeight)
    player.init(screenWidth, screenHeight)
    bullet.init()
    enemy.init(screenWidth, screenHeight)
    
    -- Set default font
    love.graphics.setFont(love.graphics.newFont(16))
    
    -- Initialize joystick support
    updateJoystickAssignments()
end

function love.update(dt)
    -- Check for escape key to quit
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    
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
    -- Update joystick assignments
    updateJoystickAssignments()
    
    -- Player 1 controls
    local p1 = player.getPlayer(1)
    if p1 and not p1.destroyed then
        local dx, dy = 0, 0
        local shoot = false
        
        -- Check joystick input first (if available)
        if joysticks.player1 then
            local js = joysticks.player1
            -- Left stick or D-pad for movement
            dx = js:getAxis(1) or 0  -- Left stick X
            dy = js:getAxis(2) or 0  -- Left stick Y
            
            -- D-pad as backup
            if math.abs(dx) < 0.3 then
                if js:isGamepadDown("dpleft") then dx = -1 end
                if js:isGamepadDown("dpright") then dx = 1 end
            end
            if math.abs(dy) < 0.3 then
                if js:isGamepadDown("dpup") then dy = -1 end
                if js:isGamepadDown("dpdown") then dy = 1 end
            end
            
            -- Shooting (A button, right shoulder, or right trigger)
            shoot = js:isGamepadDown("a") or js:isGamepadDown("rightshoulder") or js:getAxis(6) > 0.5
        else
            -- Fallback to keyboard (arrow keys + right control)
            if love.keyboard.isDown("up") then dy = -1 end
            if love.keyboard.isDown("down") then dy = 1 end
            if love.keyboard.isDown("left") then dx = -1 end
            if love.keyboard.isDown("right") then dx = 1 end
            shoot = love.keyboard.isDown("rctrl")
        end
        
        -- Apply movement
        if math.abs(dx) > 0.3 or math.abs(dy) > 0.3 or dx ~= 0 or dy ~= 0 then
            player.movePlayer(1, dx, dy)
        end
        
        -- Handle shooting
        if shoot and player.canShoot(1) then
            local x, y = player.getPlayerPosition(1)
            bullet.createBullet(x + 15, y, 1)
            player.resetShootTimer(1)
        end
    end
    
    -- Player 2 controls
    local p2 = player.getPlayer(2)
    if p2 and not p2.destroyed then
        local dx, dy = 0, 0
        local shoot = false
        
        -- Check joystick input first (if available)
        if joysticks.player2 then
            local js = joysticks.player2
            -- Left stick or D-pad for movement
            dx = js:getAxis(1) or 0
            dy = js:getAxis(2) or 0
            
            -- D-pad as backup
            if math.abs(dx) < 0.3 then
                if js:isGamepadDown("dpleft") then dx = -1 end
                if js:isGamepadDown("dpright") then dx = 1 end
            end
            if math.abs(dy) < 0.3 then
                if js:isGamepadDown("dpup") then dy = -1 end
                if js:isGamepadDown("dpdown") then dy = 1 end
            end
            
            -- Shooting (A button, right shoulder, or right trigger)
            shoot = js:isGamepadDown("a") or js:isGamepadDown("rightshoulder") or js:getAxis(6) > 0.5
        else
            -- Fallback to keyboard (WASD + spacebar)
            if love.keyboard.isDown("w") then dy = -1 end
            if love.keyboard.isDown("s") then dy = 1 end
            if love.keyboard.isDown("a") then dx = -1 end
            if love.keyboard.isDown("d") then dx = 1 end
            shoot = love.keyboard.isDown("space")
        end
        
        -- Apply movement
        if math.abs(dx) > 0.3 or math.abs(dy) > 0.3 or dx ~= 0 or dy ~= 0 then
            player.movePlayer(2, dx, dy)
        end
        
        -- Handle shooting
        if shoot and player.canShoot(2) then
            local x, y = player.getPlayerPosition(2)
            bullet.createBullet(x + 15, y, 2)
            player.resetShootTimer(2)
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
    
    -- Player 1 controls
    if joysticks.player1 then
        local jsName = joysticks.player1:getName():sub(1, 15) -- Truncate long names
        love.graphics.print("P1: " .. jsName, screenWidth - 250, screenHeight - 80)
        love.graphics.print("    Stick/D-pad + A/RT", screenWidth - 250, screenHeight - 65)
    else
        love.graphics.print("P1: Arrows + RCtrl", screenWidth - 200, screenHeight - 80)
    end
    
    -- Player 2 controls
    if joysticks.player2 then
        local jsName = joysticks.player2:getName():sub(1, 15)
        love.graphics.print("P2: " .. jsName, screenWidth - 250, screenHeight - 50)
        love.graphics.print("    Stick/D-pad + A/RT", screenWidth - 250, screenHeight - 35)
    else
        love.graphics.print("P2: WASD + Space", screenWidth - 200, screenHeight - 60)
    end
    
    love.graphics.print("ESC: Quit Game", screenWidth - 200, screenHeight - 20)
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

function updateJoystickAssignments()
    -- Get all available joysticks
    local availableJoysticks = love.joystick.getJoysticks()
    
    -- Clear current assignments if joysticks are no longer connected
    if joysticks.player1 and not joysticks.player1:isConnected() then
        joysticks.player1 = nil
    end
    if joysticks.player2 and not joysticks.player2:isConnected() then
        joysticks.player2 = nil
    end
    
    -- Assign joysticks in order of connection
    for i, joystick in ipairs(availableJoysticks) do
        if joystick:isGamepad() then  -- Only use gamepads
            if not joysticks.player1 then
                joysticks.player1 = joystick
            elseif not joysticks.player2 and joystick ~= joysticks.player1 then
                joysticks.player2 = joystick
                break
            end
        end
    end
end

-- Love2D joystick callbacks
function love.joystickadded(joystick)
    updateJoystickAssignments()
end

function love.joystickremoved(joystick)
    updateJoystickAssignments()
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
