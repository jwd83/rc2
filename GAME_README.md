# Life Force Clone - Horizontal Shmup Prototype

A 2D shoot 'em up (shmup) game prototype inspired by the NES game Life Force, built with LÖVE2D.
Features fullscreen 16:9 widescreen horizontal gameplay!

## Controls

### Automatic Joystick Support 🎮
The game automatically detects and assigns controllers:
- **First joystick** plugged in becomes Player 1's controller
- **Second joystick** plugged in becomes Player 2's controller
- **Hot-swappable** - plug/unplug controllers anytime during gameplay
- **Keyboard fallback** - if no controller is available, uses keyboard controls

### Joystick Controls (Xbox/PlayStation style)
- **Movement**: Left analog stick OR D-pad
- **Shoot**: A button OR Right shoulder button OR Right trigger

### Keyboard Fallback Controls

#### Player 1 (Red Triangle)
- **Movement**: Arrow keys (↑↓←→)
- **Shoot**: Right Control key

#### Player 2 (Blue Triangle)  
- **Movement**: WASD keys
- **Shoot**: Spacebar

### Game Controls
- **Quit Game**: Escape key

## Game Features

- **Fullscreen 16:9 widescreen gameplay** - automatic fullscreen mode
- **Horizontal scrolling action** - classic side-scrolling shmup style
- **Two-player cooperative gameplay**
- **Scrolling starfield background** with parallax effect moving right to left
- **Simple collision detection** between bullets/enemies and ships/enemies
- **Score system** with individual counters for both players
- **Lives system** with 3 shared lives
- **Auto-restart** when all lives are lost
- **Progressive difficulty** - enemies spawn faster over time
- **Multiple enemy movement patterns**:
  - Straight left movement
  - Diagonal movement with vertical components
  - Sinusoidal wave movement

## Project Structure

```
rc2/
├── main.lua      - Main game loop and initialization
├── starfield.lua - Scrolling starfield background system
├── player.lua    - Player ship management (both red and blue triangles)
├── bullet.lua    - Projectile system for player shots
├── enemy.lua     - Enemy spawning and movement system
└── love.exe      - LÖVE2D game engine executable
```

## How to Run

1. Make sure all game files are in the same directory as `love.exe`
2. Open command prompt/terminal in the game directory
3. Run: `love.exe .` (Windows) or `love .` (macOS/Linux)

Alternatively, you can drag the game folder onto the `love.exe` executable.

## Technical Details

- **Engine**: LÖVE2D (Lua game framework)
- **Graphics**: Simple 2D shapes (no sprites - hitbox test version)
- **Delta time movement** for consistent speed regardless of frame rate
- **Modular code structure** with clear separation of concerns
- **Clean, commented Lua code** following game development best practices

## Game Objects

- **Players**: Colored triangles (red/blue) positioned on the left side, pointing right
- **Bullets**: Small white circles that travel horizontally to the right
- **Enemies**: Colored rectangles spawning from the right and moving left
- **Stars**: White dots of varying sizes creating right-to-left parallax scrolling

## Scoring

- **10 points** per enemy destroyed
- **Individual scores** tracked for both players
- **Shared lives system** - when either player is hit, the team loses a life
- **Game over** when all 3 lives are exhausted
- **Auto-restart** after 3 seconds with score reset

Enjoy the game!