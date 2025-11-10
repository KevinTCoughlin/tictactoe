# GitHub Copilot Instructions for Tic-Tac-Toe iOS

## Project Overview
This is a Tic-Tac-Toe game built with Swift and SpriteKit for iOS. The project targets iOS 17.0+ and uses modern Swift concurrency features.

## Technology Stack
- **Language**: Swift 6.0+
- **Framework**: SpriteKit for game rendering and animations
- **Platform**: iOS 17.0+
- **Game Services**: Game Center integration for multiplayer and achievements
- **Architecture**: Scene-based architecture with GameScene as the main game controller

## Code Style Guidelines

### Swift Conventions
- Use Swift naming conventions (camelCase for variables/methods, PascalCase for types)
- Prefer `let` over `var` for immutability
- Use type inference where appropriate
- Add documentation comments for public APIs using `///`
- Use `MARK:` comments to organize code sections

### SpriteKit Best Practices
- Keep game logic in scene classes (GameScene)
- Use SKAction for animations and sequences
- Leverage node hierarchy for organization
- Use `zPosition` to control rendering order
- Implement `touchesBegan` for touch handling

### Swift 6 Concurrency
- Use `async`/`await` for asynchronous operations
- Use `@MainActor` for UI-related code
- Follow `Sendable` protocol requirements
- Use structured concurrency with Task groups when needed

### Game Center Integration
- Authenticate players on app launch
- Handle authentication failures gracefully
- Use GameKitManager singleton for centralized Game Center operations
- Always check authentication status before Game Center operations

## Project Structure

```
tictactoe/
├── tictactoe Shared/        # Shared game code
│   ├── GameScene.swift      # Main game scene with tic-tac-toe logic
│   ├── GameKitManager.swift # Game Center integration
│   ├── GameCenterStatusView.swift
│   ├── GameCenterButton.swift
│   └── Assets.xcassets      # Images and assets
├── tictactoe iOS/           # iOS-specific code
│   ├── AppDelegate.swift    # App lifecycle
│   └── GameViewController.swift
└── tictactoe.xcodeproj/     # Xcode project
```

## Key Classes

### GameScene
- Inherits from `SKScene`
- Manages the game board, player moves, and win detection
- Handles touch input for player interactions
- Renders X and O marks, grid lines, and winning animations

### GameKitManager
- Singleton for Game Center operations
- Handles player authentication
- Manages leaderboards and achievements
- Conforms to `ObservableObject` for SwiftUI integration

## Common Patterns

### Scene Setup
```swift
override func didMove(to view: SKView) {
    // Initialize scene when presented
}
```

### Touch Handling
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    // Handle touch at location
}
```

### SpriteKit Animations
```swift
let action = SKAction.sequence([
    SKAction.fadeIn(withDuration: 0.3),
    SKAction.wait(forDuration: 1.0),
    SKAction.fadeOut(withDuration: 0.3)
])
node.run(action)
```

## Testing Considerations
- Test on both iPhone and iPad simulators
- Verify Game Center integration in sandbox environment
- Test touch interactions and game logic
- Validate win conditions and draw scenarios

## Build Configuration
- **Deployment Target**: iOS 17.0
- **Swift Version**: 6.0
- **Code Signing**: Automatic (development)
- **Architectures**: arm64 (device), x86_64/arm64 (simulator)

## CI/CD
- GitHub Actions workflows validate builds and code quality
- SwiftLint enforces code style
- Automated builds run on push and PR

## Common Tasks

### Adding a New Feature
1. Update GameScene for game logic changes
2. Add SpriteKit nodes for visual elements
3. Handle touch input if interactive
4. Update Game Center integration if needed
5. Test on simulator and device

### Debugging Tips
- Use `print()` for quick debugging
- Enable SpriteKit debugging in scheme (show physics, node counts, etc.)
- Use Xcode's View Debugger for scene hierarchy
- Check console for Game Center authentication errors

## Performance Optimization
- Minimize node creation in update loops
- Use texture atlases for frequently used images
- Cache SKAction sequences
- Profile with Instruments (Time Profiler, Allocations)

## Dependencies
- None (pure SpriteKit project, no external dependencies)
- Game Center framework (built-in)

## Additional Resources
- [SpriteKit Programming Guide](https://developer.apple.com/documentation/spritekit)
- [Game Center Documentation](https://developer.apple.com/game-center/)
- [Swift Evolution](https://github.com/apple/swift-evolution)
