# Tic-Tac-Toe iOS

[![iOS Build & Test](https://github.com/KevinTCoughlin/tictactoe/actions/workflows/ios-build.yml/badge.svg)](https://github.com/KevinTCoughlin/tictactoe/actions/workflows/ios-build.yml)
[![Swift Code Quality](https://github.com/KevinTCoughlin/tictactoe/actions/workflows/swift-quality.yml/badge.svg)](https://github.com/KevinTCoughlin/tictactoe/actions/workflows/swift-quality.yml)

A modern Tic-Tac-Toe game built with Swift and SpriteKit for iOS.

## Features

- 🎮 Classic Tic-Tac-Toe gameplay
- 🎨 Built with SpriteKit for smooth animations
- 🏆 Game Center integration for achievements and leaderboards
- 📱 Native iOS experience
- 🎯 Optimized for iPhone and iPad

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

## Building the Project

### Prerequisites

1. Install Xcode from the Mac App Store
2. Open Terminal and navigate to the project directory

### Build Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/KevinTCoughlin/tictactoe.git
   cd tictactoe
   ```

2. Open the project in Xcode:
   ```bash
   open tictactoe.xcodeproj
   ```

3. Select a simulator or device target

4. Build and run (⌘R)

### Command Line Build

Build for iOS Simulator:
```bash
xcodebuild clean build \
  -project tictactoe.xcodeproj \
  -scheme "tictactoe iOS" \
  -configuration Release \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

## Project Structure

```
tictactoe/
├── tictactoe Shared/        # Shared game logic and scenes
│   ├── GameScene.swift      # Main game scene
│   ├── GameKitManager.swift # Game Center integration
│   └── Assets.xcassets      # App icons and images
├── tictactoe iOS/           # iOS-specific code
│   ├── AppDelegate.swift    # App lifecycle
│   └── GameViewController.swift
└── tictactoe.xcodeproj/     # Xcode project files
```

## Game Center Setup

The app includes Game Center integration for multiplayer and achievements. See the documentation in `tictactoe Shared/GAME_CENTER_SETUP.md` for setup instructions.

## Continuous Integration

This project uses GitHub Actions for automated building and testing:

- **iOS Build & Test**: Validates builds on every push and pull request
- **Swift Code Quality**: Runs SwiftLint and format checks

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is available for personal and educational use.

## Author

Created by Kevin T. Coughlin

---

Built with ❤️ using Swift and SpriteKit
