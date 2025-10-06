Create a 2D shoot 'em up (shmup) game prototype using LÖVE2D inspired by the NES game Life Force.

Requirements:

The game uses only simple 2D shapes (no sprites or art assets) to represent everything — this is an early hitbox test version.

The background is a continuously scrolling starfield made of white dots of varying speeds and sizes for parallax effect.

Player 1’s ship is a red triangle, and Player 2’s ship is a blue triangle.

Both players can move freely within the screen bounds.

Player 1 controls: arrow keys to move, right control key to shoot.

Player 2 controls: WASD to move, spacebar to shoot.

Player shots are small white circles that travel straight forward.

Enemies are randomly spawning colored rectangles that drift downward or sideways depending on the stage type.

Include simple collision detection between bullets and enemies, and between ships and enemies.

Include score counters for both players and a shared lives counter (3 total lives).

The game restarts automatically when all lives are lost.

Write clean, modular Lua code with clear comments and organization (e.g. player.lua, bullet.lua, enemy.lua, main.lua, starfield.lua).

Use delta time for movement to ensure consistent speed regardless of frame rate.

Include a short README.md explaining controls and project structure.

Make the project ready to run by dropping into a folder and launching with love ..

Stretch goals (if time/complexity allows):

Add basic power-ups (increase bullet rate or double shot).

Add a slow background music loop (optional).

Add simple particle effects for explosions (use colored circles expanding and fading).