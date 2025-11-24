# 🎮 Tic-Tac-Toe iOS Game

A modern Tic-Tac-Toe game built with Swift and SpriteKit for iOS, featuring smooth animations, Game Center integration, and a clean architecture.

## 🚨 Important: macOS/Xcode Required

**This is an iOS application that requires macOS and Xcode to build and run.**

- ✅ **Supported**: macOS with Xcode 15+
- ❌ **Not Supported**: GitHub Codespaces, Linux, Windows, or containerized development

While you can use GitHub Codespaces or VS Code Dev Containers to:
- Browse and edit Swift code
- Review pull requests
- Update documentation
- Modify CI/CD workflows

You **cannot** build or run the iOS app without macOS and Xcode.

## 📋 Requirements

### For Building & Running
- **macOS** 14.0 or later
- **Xcode** 15.0 or later
- **iOS Simulator** or a physical iOS device running iOS 17.0+

### For Code Editing Only
- Any platform with VS Code and the Swift extension (syntax highlighting only)
- GitHub Codespaces (limited to code review and documentation)

## 🚀 Getting Started

### On macOS

1. **Clone the repository:**
   ```bash
   git clone https://github.com/KevinTCoughlin/tictactoe.git
   cd tictactoe
   ```

2. **Open in Xcode:**
   ```bash
   open tictactoe.xcodeproj
   ```

3. **Select a target:**
   - Choose "tictactoe iOS" scheme
   - Select an iOS Simulator (e.g., iPhone 16 Pro) or connected device

4. **Build and Run:**
   - Press `⌘R` or click the Play button
   - The app will launch in the simulator or on your device

### Command Line Build (macOS only)

```bash
xcodebuild -project tictactoe.xcodeproj \
  -scheme "tictactoe iOS" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## 🏗️ Project Structure

```
tictactoe/
├── tictactoe Shared/           # Shared game code
│   ├── GameScene.swift         # Main game scene
│   ├── GameBoard.swift         # Game logic
│   ├── GameKitManager.swift    # Game Center integration
│   ├── GridLayout.swift        # Layout calculations
│   ├── GridRenderer.swift      # Grid rendering
│   ├── MarkRenderer.swift      # X/O mark rendering
│   ├── WinningLineAnimator.swift
│   ├── SoundManager.swift      # Sound effects
│   └── Assets.xcassets         # Images and assets
├── tictactoe iOS/              # iOS-specific code
│   ├── AppDelegate.swift       # App lifecycle
│   └── GameViewController.swift
├── tictactoeTests/             # Unit tests
└── tictactoe.xcodeproj/        # Xcode project
```

## 🎮 Features

- ✨ Smooth animations with SpriteKit
- 🎯 Two-player local gameplay
- 🏆 Game Center integration (leaderboards & achievements)
- 🔊 Sound effects for moves and wins
- 🎨 Clean, modern UI
- ♻️ Well-architected, testable code
- 📱 Supports iPhone and iPad

## 🧪 Testing

Run tests in Xcode:
```
⌘U (Command + U)
```

Or from command line (macOS only):
```bash
xcodebuild test \
  -project tictactoe.xcodeproj \
  -scheme "tictactoe iOS" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## 🛠️ Technology Stack

- **Language**: Swift 6.0+
- **Framework**: SpriteKit
- **Platform**: iOS 17.0+
- **Services**: Game Center
- **Architecture**: Scene-based with MVVM patterns

## 📱 Minimum iOS Version

iOS 17.0+ (targets the latest iOS features and APIs)

## 🤝 Contributing

Contributions are welcome! However, please note:

1. **You must have macOS and Xcode** to test changes to the iOS app
2. Fork the repository and create a branch
3. Make your changes and test thoroughly
4. Submit a pull request with a clear description

For code-only changes (docs, CI/CD), you can use any platform.

## 📄 License

[Add your license here]

## 🙋 FAQ

### Q: Can I develop this app on Windows/Linux?
**A:** No. iOS development requires macOS and Xcode. You can view and edit code on other platforms, but cannot build or run the app.

### Q: Can I use GitHub Codespaces?
**A:** Codespaces can be used for code review, documentation, and minor edits, but you cannot build or test the iOS app. See [.devcontainer/README.md](.devcontainer/README.md) for details.

### Q: What about Swift Playgrounds on iPad?
**A:** This project uses SpriteKit and Xcode project files which are not compatible with Swift Playgrounds.

### Q: Can I use a cloud Mac service?
**A:** Yes! Services like MacStadium, AWS Mac instances, or GitHub's macOS runners can build the project, but they require proper setup and Xcode installation.

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Check existing issues for similar problems
- Review the [.devcontainer/README.md](.devcontainer/README.md) for development environment details

---

**Built with ❤️ using Swift and SpriteKit**
