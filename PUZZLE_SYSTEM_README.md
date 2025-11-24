# ML-Powered Puzzle System

An intelligent puzzle system for tic-tac-toe that combines hand-crafted puzzles with machine learning infrastructure for future personalization.

## 🎯 Overview

This puzzle system provides a production-ready implementation using static puzzles while laying the groundwork for ML-powered puzzle generation based on user behavior and preferences.

### Key Features

- **15 Hand-Crafted Puzzles** across 4 difficulty levels
- **3 Puzzle Types**: One-move wins, two-move wins, and defensive puzzles
- **GameplayKit Integration**: Intelligent move analysis using `GKMinmaxStrategist`
- **Progression System**: Automatic difficulty adjustment based on performance
- **Streak Tracking**: Daily puzzle streaks with push notifications
- **Data Collection**: Infrastructure for collecting ML training data
- **ML-Ready**: Clear hooks for Core ML model integration

## 📐 Architecture

### Core Components

```
PuzzleModels.swift          - Data models (GamePuzzle, UserPuzzleProfile, etc.)
GameplayKitIntegration.swift - GKGameModel implementation for strategic analysis
PuzzleGenerator.swift        - Hybrid puzzle generation (static + ML placeholder)
PuzzleManager.swift          - Central coordinator for puzzle system
PuzzleScene.swift            - SpriteKit scene for puzzle UI
PuzzleNotificationManager.swift - Daily notifications and reminders
PuzzleViewController.swift   - iOS view controller for puzzle mode
```

### Data Models

#### GamePuzzle
Represents a puzzle challenge with:
- Board state (via bitmasks)
- Puzzle type and difficulty
- Solution moves
- Metadata (tags, hints, source)

#### UserPuzzleProfile
Tracks user progress:
- Current difficulty level
- Streak tracking (current and longest)
- Statistics by puzzle type
- Performance metrics for ML personalization

#### PuzzleStatistics
Per-puzzle statistics:
- Attempts and solves
- Success rate
- Average solve time
- User ratings

## 🎮 Usage

### Basic Integration

The puzzle system is automatically initialized in `AppDelegate`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Puzzle system initialization happens automatically
    Task { @MainActor in
        await initializePuzzleSystem()
    }
    return true
}
```

### Accessing Puzzle Mode

From the main game screen, tap the puzzle button (🧩) to enter puzzle mode.

### Generating Puzzles

```swift
// Generate a puzzle for the current user
let puzzle = PuzzleManager.shared.generatePuzzle()

// Generate a specific type
let defensivePuzzle = PuzzleManager.shared.generatePuzzle(type: .defensive)

// Get today's daily puzzle
let dailyPuzzle = PuzzleManager.shared.getDailyPuzzle()
```

### Recording Progress

```swift
// Record puzzle completion
PuzzleManager.shared.recordPuzzleCompletion(
    puzzle: puzzle,
    solved: true,
    timeInSeconds: 15.0
)

// Get user statistics
let stats = PuzzleManager.shared.getSummaryStatistics()
print("Streak: \(stats.currentStreak)")
print("Success Rate: \(stats.successRate)%")
```

## 🤖 ML Integration (Future)

### Data Collection

The system automatically collects anonymized data for ML training:

```swift
// Export collected training data
if let data = PuzzleManager.shared.exportTrainingData() {
    // Upload to training pipeline
    uploadToTrainingService(data)
}
```

### Training Pipeline

1. **Collect Data**: System automatically records `PuzzleAttempt` objects
2. **Export**: Use `exportTrainingData()` to get JSON training data
3. **Train Model**: Train Core ML model with collected data
4. **Deploy**: Add trained `.mlmodelc` file to app bundle

### Integrating Trained Model

Once you have a trained Core ML model:

1. Add the `.mlmodelc` file to your Xcode project
2. Update `PuzzleGenerator.loadMLModelIfAvailable()`:

```swift
private func loadMLModelIfAvailable() {
    guard let modelURL = Bundle.main.url(
        forResource: "PuzzleGenerator", 
        withExtension: "mlmodelc"
    ) else { return }
    
    do {
        self.mlModel = try MLModel(contentsOf: modelURL)
        self.preferMLGeneration = true
        print("✅ ML model loaded successfully")
    } catch {
        print("❌ Failed to load ML model: \(error)")
    }
}
```

3. Implement `generateMLPuzzle()`:

```swift
private func generateMLPuzzle(
    for profile: UserPuzzleProfile,
    type: PuzzleType?
) -> GamePuzzle? {
    guard let model = mlModel else { return nil }
    
    // 1. Prepare features from user profile
    let features = extractFeatures(from: profile, type: type)
    
    // 2. Run inference
    guard let prediction = try? model.prediction(from: features) else {
        return nil
    }
    
    // 3. Parse prediction to GamePuzzle
    let puzzle = parsePrediction(prediction, profile: profile)
    
    // 4. Validate puzzle
    guard strategist.validatePuzzle(puzzle) else { return nil }
    
    return puzzle
}
```

## 🧪 GameplayKit Integration

The system uses Apple's GameplayKit for intelligent move analysis:

### Strategic Analysis

```swift
let strategist = PuzzleStrategist()

// Find optimal move
if let bestMove = strategist.findBestMove(for: board) {
    print("Best move: \(bestMove)")
}

// Find all winning moves
let winningMoves = strategist.findWinningMoves(for: board)

// Find blocking moves
let blockingMoves = strategist.findBlockingMoves(for: board)

// Validate puzzle solution
let isValid = strategist.validatePuzzle(puzzle)
```

### Difficulty Estimation

The strategist can automatically estimate puzzle difficulty:

```swift
let difficulty = strategist.estimateDifficulty(for: board)
print("Estimated difficulty: \(difficulty)")
```

## 📊 Puzzle Types

### One-Move Win
Find the winning move in a single turn.

```
Example:
X X _
O O _
_ _ _

Solution: Cell 2 (complete row)
```

### Two-Move Win
Find a sequence that guarantees victory in two moves.

```
Example:
X _ _
_ X _
O O _

Solution: [8, 2] (create fork)
```

### Defensive
Block opponent's winning move.

```
Example:
O O _
X _ _
_ _ _

Solution: Cell 2 (block row)
```

## 🔔 Notifications

### Daily Puzzle Reminders

Scheduled automatically at user's preferred time (default 9 AM):

```swift
// Change notification time
PuzzleNotificationManager.shared.updateNotificationTime(hour: 10) // 10 AM
```

### Streak Reminders

Sent if user hasn't completed puzzle within 24 hours:

```swift
PuzzleNotificationManager.shared.scheduleStreakReminder()
```

### Re-engagement

Sent after user is inactive for specified days:

```swift
PuzzleNotificationManager.shared.scheduleReengagementNotification(daysInactive: 3)
```

## 📈 Progression System

### Difficulty Levels

1. **Beginner** (⭐️) - 10 points
   - Simple one-move wins
   - Basic defensive moves

2. **Intermediate** (⭐️⭐️) - 25 points
   - Multiple threats
   - Fork opportunities

3. **Advanced** (⭐️⭐️⭐️) - 50 points
   - Two-move sequences
   - Complex defense

4. **Expert** (⭐️⭐️⭐️⭐️) - 100 points
   - Master-level tactics
   - Forced win sequences

### Automatic Leveling

Users automatically level up when:
- Success rate > 80%
- At least 10 puzzles attempted at current level

## 🧪 Testing

Comprehensive test suite included:

```bash
# Run tests
xcodebuild test -scheme "tictactoe iOS" -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Test coverage includes:
- Puzzle model creation and validation
- GameplayKit integration
- Strategic move analysis
- User profile tracking
- Puzzle generation
- Statistics calculation

### Validate Static Puzzles

```swift
let generator = PuzzleGenerator()
let results = generator.validateAllPuzzles()

// Check for invalid puzzles
let invalid = results.filter { !$0.value }
print("Invalid puzzles: \(invalid.keys)")
```

## 🎨 UI Customization

### Puzzle Scene Configuration

Customize colors, fonts, and animations in `PuzzleScene.Configuration`:

```swift
private struct Configuration {
    static let successColor: SKColor = .systemGreen
    static let failureColor: SKColor = .systemRed
    static let hintColor: SKColor = .systemOrange
    static let animationDuration: TimeInterval = 0.3
    // ... more options
}
```

### Custom Puzzle Generation

Add your own puzzles to the static library:

```swift
puzzles.append(GamePuzzle(
    id: "custom_puzzle_1",
    type: .oneMove,
    difficulty: .intermediate,
    xMask: 0b100_010_000,
    oMask: 0b001_001_000,
    currentPlayer: .x,
    solution: [8],
    hint: "Your custom hint",
    tags: ["custom", "special"]
))
```

## 📝 Best Practices

### Data Collection
- Collect at least 10,000 puzzle attempts before training ML model
- Include diverse difficulty levels and puzzle types
- Anonymize user data before upload

### Puzzle Design
- Ensure each puzzle has a unique optimal solution
- Use `PuzzleStrategist` to validate all puzzles
- Progressive difficulty increase
- Clear, helpful hints

### Performance
- Puzzles are lightweight (bitmask-based)
- GameplayKit strategist is efficient for tic-tac-toe
- Consider caching daily puzzles
- Batch save statistics to reduce I/O

## 🐛 Debugging

Enable debug logging:

```swift
// Print puzzle manager status
let stats = PuzzleManager.shared.getSummaryStatistics()
print("Current difficulty: \(stats.currentDifficulty)")
print("Streak: \(stats.currentStreak)")

// Print pending notifications
PuzzleNotificationManager.shared.printPendingNotifications()

// Validate all puzzles
let results = PuzzleGenerator().validateAllPuzzles()
print("Validation results: \(results)")
```

## 📚 Additional Resources

- [GameplayKit Documentation](https://developer.apple.com/documentation/gameplaykit)
- [Core ML Documentation](https://developer.apple.com/documentation/coreml)
- [User Notifications Documentation](https://developer.apple.com/documentation/usernotifications)
- [SpriteKit Programming Guide](https://developer.apple.com/documentation/spritekit)

## 🤝 Contributing

When adding new puzzles:
1. Follow existing puzzle format
2. Use descriptive IDs and tags
3. Validate with `PuzzleStrategist`
4. Add appropriate hints
5. Test across all difficulty levels

## 📄 License

Part of the tictactoe project. See main repository for license information.
