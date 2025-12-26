# Candy Crush 🍬

A Candy Crush clone built with Love2D in Lua, featuring a clean Catppuccin Mocha theme.

## 🎮 Gameplay

Match 3 or more candies of the same color by swapping adjacent tiles. The game features:
- **8x8 grid** with colorful candies
- **Score tracking** and move counter
- **Automatic match detection** and cascade effects
- **Smooth animations** and responsive controls
- **Beautiful Catppuccin Mocha theme**

## 🎯 How to Play

1. Click on a candy to select it (highlighted with a yellow border)
2. Click on an adjacent candy to swap them
3. Match 3 or more candies of the same color to score points
4. Candies automatically drop to fill empty spaces
5. Chain reactions create combo opportunities

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
├── main.lua          # Main game loop and window setup
├── board.lua         # Game board logic and match detection
├── candy.lua         # Candy rendering and properties
├── candy.mp4         # Gameplay demonstration video
└── README.md         # This file
```

## 🎨 Features

### Game Mechanics
- **Match Detection**: Automatic detection of 3+ matches horizontally and vertically
- **Candy Swapping**: Click-to-swap interface with validation
- **Gravity System**: Candies drop to fill empty spaces
- **Score System**: 10 points per candy in matches
- **Move Counter**: Track your moves

### Visual Design
- **Catppuccin Mocha Theme**: Dark mode with vibrant accent colors
- **6 Candy Types**: Pink, Green, Blue, Yellow, Mauve, and Teal
- **Rounded Rectangles**: Modern, candy-like appearance
- **Highlight Effects**: Selected candy visualization
- **Clean UI**: Score and move display

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

- **Board Class**: Manages game state, match detection, and candy movement
- **Candy Class**: Handles individual candy rendering and properties
- **Match Algorithm**: Efficient detection of horizontal/vertical matches
- **Gravity System**: Physics-based candy dropping and refilling

## 🎮 Controls

- **Mouse Left Click**: Select and swap candies
- **ESC**: Exit game (Love2D default)

## 📈 Future Enhancements

- [ ] Particle effects for matches
- [ ] Sound effects and background music
- [ ] Level progression system
- [ ] Special candy types (striped, wrapped, etc.)
- [ ] High score tracking
- [ ] Timer-based challenges
- [ ] Power-ups and boosters

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- [Love2D](https://love2d.org/) - Amazing 2D game framework
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Beautiful color scheme

---

*Built with ❤️ using Love2D*