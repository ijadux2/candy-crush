# Candy Crush 🍬

A feature-rich Candy Crush clone built with Love2D in Lua, featuring progressive difficulty and modern visual effects.

## 🎮 Gameplay

Match 3 or more candies of the same color by swapping adjacent tiles. The game features:
- **Progressive Difficulty** - Gets harder as you advance through levels
- **Dynamic Scoring** - Points increase with difficulty and match length
- **8x8 grid** with colorful candies (4-6 types based on level)
- **Level System** - Complete targets to advance through increasingly challenging levels
- **Visual Effects** - Screen shake, glow effects, and smooth animations
- **Modern UI** - Side panel with level progression and statistics
- **Beautiful Catppuccin Mocha theme** with JetBrains Mono Nerd Font icons

## 🎯 How to Play

1. Click on a candy to select it (highlighted with a yellow border)
2. Click on an adjacent candy to swap them
3. Match 3 or more candies of same color to score points
4. Candies automatically drop to fill empty spaces
5. Chain reactions create combo opportunities
6. **Reach target score before running out of moves to complete the level**
7. **Difficulty increases** with each new level (fewer candy colors, fewer moves)

## 🚀 Installation & Running

### Prerequisites
- [Love2D](https://love2d.org/) (version 11.0 or higher)

### Instructions
1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd candy-crush
   ```

2. Run the game:
   ```bash
   love .
   ```

## 📁 Project Structure

```
candy-crush/
├── main.lua          # Main game loop, UI rendering, and visual effects
├── board.lua         # Game board logic, level progression, and match detection
├── candy.lua         # Candy rendering and properties
├── candy.mp4         # Gameplay demonstration video
└── README.md         # This file
```

## 🎨 Features

### Game Mechanics
- **Progressive Difficulty**: Dynamic difficulty scaling based on level progression
- **Match Detection**: Automatic detection of 3+ matches horizontally and vertically
- **Candy Swapping**: Click-to-swap interface with validation
- **Gravity System**: Candies drop to fill empty spaces
- **Dynamic Scoring**: Points increase with difficulty level and match length
- **Move Limits**: Each level has a maximum move limit
- **Level Progression**: Complete targets to advance through increasingly challenging levels

### Visual Design
- **Modern UI**: Professional side panel with level progression and statistics
- **Visual Effects**: Screen shake on matches, glow effects on level completion
- **Catppuccin Mocha Theme**: Dark mode with vibrant accent colors
- **Dynamic Candy Types**: 4-6 candy types based on difficulty level
- **Nerd Font Icons**: Beautiful JetBrains Mono icons throughout the interface
- **Progress Bars**: Visual indicators for score progress and remaining moves
- **Level Completion Popups**: Celebratory messages with detailed statistics
- **Round Corners**: Modern, polished UI elements
- **Highlight Effects**: Selected candy visualization
- **Large, Clear Fonts**: Optimized for readability

## 🎥 Gameplay Demo

![Gameplay Video](candy.mp4)

*Watch the gameplay demonstration to see the game in action!*

## 🛠️ Technical Details

- **Framework**: Love2D 11.x
- **Language**: Lua
- **Architecture**: Object-oriented with Board and Candy classes
- **Theme**: Catppuccin Mocha dark theme
- **Grid Size**: 8x8 (64 tiles total)

### Key Components

- **Board Class**: Manages game state, level progression, match detection, and candy movement
- **Candy Class**: Handles individual candy rendering and properties
- **Match Algorithm**: Efficient detection of horizontal/vertical matches
- **Gravity System**: Physics-based candy dropping and refilling
- **Visual Effects System**: Screen shake, glow effects, and post-processing
- **Utility Functions**: Color conversion, easing, and interpolation helpers
- **UI System**: Modern interface with progress bars and level tracking

## 🎮 Controls

- **Mouse Left Click**: Select and swap candies
- **ESC**: Exit game (Love2D default)

## 📈 Future Enhancements

- [ ] Particle effects for matches and explosions
- [ ] Sound effects and background music
- [ ] Special candy types (striped, wrapped, color bomb)
- [ ] High score tracking and leaderboards
- [ ] Timer-based challenges
- [ ] Power-ups and boosters
- [ ] More advanced post-processing effects
- [ ] Animated candy transitions and special effects
- [ ] Multiplayer or online features
- [ ] Achievement system

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- [Love2D](https://love2d.org/) - Amazing 2D game framework
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Beautiful color scheme

---

*Built with ❤️ using Love2D*
