# AI-Powered Features for Tic-Tac-Toe MVP

This document outlines how to leverage Apple's Foundation Models framework to add intelligent features to your tic-tac-toe game.

## Overview

All AI features use Apple's **on-device Foundation Models** framework, which means:
- ✅ Complete privacy - no data leaves the device
- ✅ No API keys or cloud services required
- ✅ Works offline
- ✅ Free to use
- ⚠️ Requires devices with Apple Intelligence support (iPhone 15 Pro+, M1+ Macs, etc.)

## 🎯 MVP Feature Implementations

### 1. AI Game Coach (`AIGameCoach.swift`)
**Value Proposition:** Helps players improve their skills with contextual advice

**Features:**
- Real-time strategic hints based on current board state
- Explains why moves are good or bad
- Adjustable difficulty levels (beginner, intermediate, advanced)
- Move explanations after each play

**Usage:**
```swift
let coach = AIGameCoach(style: .intermediate)

// Check availability
if coach.isAvailable {
    // Get advice for current game state
    let advice = try await coach.provideAdvice(for: board)
    print(advice.reasoning)              // "This blocks their winning move"
    print(advice.recommendedMove)        // 4 (center position)
    print(advice.encouragement)          // "Great defensive thinking!"
    
    // Explain a move that was made
    let explanation = try await coach.explainMove(3, on: board)
}
```

**SwiftUI Integration:**
```swift
CoachingView(board: board)
    .padding()
```

### 2. AI Opponent (`AIOpponent.swift`)
**Value Proposition:** Single-player mode with intelligent computer opponent

**Features:**
- Dynamic playing style using AI (not just hardcoded minimax)
- Multiple difficulty levels: easy, medium, hard, adaptive
- Fallback to rule-based AI when Foundation Models unavailable
- Move explanations for learning

**Usage:**
```swift
let opponent = AIOpponent(difficulty: .medium)

// Check availability
if opponent.isAvailable {
    // Get AI's next move
    let move = try await opponent.calculateMove(for: board)
    board.makeMove(at: move)
    
    // Get explanation
    if let explanation = opponent.explainLastMove() {
        print(explanation)
    }
}

// Works even without Apple Intelligence (uses fallback)
let move = try await opponent.calculateMove(for: board)
```

**SwiftUI Integration:**
```swift
AIGameView()  // Complete game with AI opponent
```

### 3. AI Commentator (`AICommentator.swift`)
**Value Proposition:** Makes games more entertaining with play-by-play commentary

**Features:**
- Real-time commentary on each move
- Multiple commentary styles: casual, enthusiastic, analytical, humorous
- Opening and closing commentary
- Mid-game analysis
- Streaming commentary for dramatic effect

**Usage:**
```swift
let commentator = AICommentator(style: .enthusiastic)

// Get commentary for a move
let commentary = try await commentator.commentOnMove(
    4,
    board: board,
    player: .x
)
print(commentary.playByPlay)   // "OH! Taking the center - brilliant!"
print(commentary.analysis)     // "This controls the most winning lines"
print(commentary.prediction)   // "X is setting up for a powerful attack"

// Opening commentary
let opening = try await commentator.openingCommentary()

// Closing commentary
let closing = try await commentator.closingCommentary(for: board)

// Stream commentary in real-time
for try await partial in commentator.streamCommentary(for: 4, board: board, player: .x) {
    print(partial.playByPlay ?? "")  // Updates as text generates
}
```

**SwiftUI Integration:**
```swift
CommentaryView(board: board, lastMove: 4, lastPlayer: .x)
    .padding()

CommentaryStylePicker(style: $commentaryStyle)
```

### 4. Natural Language Game Interface (`NaturalLanguageGameInterface.swift`)
**Value Proposition:** Play using voice or text commands instead of tapping

**Features:**
- Understands natural language commands
- Interprets strategic phrases like "block them" or "win"
- Handles ambiguity with clarification questions
- Provides friendly confirmations
- Command suggestions

**Usage:**
```swift
let interface = NaturalLanguageGameInterface()

// Interpret a command
let interpretation = try await interface.interpretCommand(
    "top left",
    for: board
)

if interpretation.needsClarification {
    print(interpretation.clarificationQuestion ?? "Could you clarify?")
} else {
    print(interpretation.confirmation)  // "Playing in the top left corner!"
    board.makeMove(at: interpretation.targetCell)
}

// Get suggestions
let suggestions = interface.getSuggestions(for: board)
// ["Play in the middle", "Take a corner", "Block their win", ...]
```

**SwiftUI Integration:**
```swift
NaturalLanguageGameView()  // Complete chat-style game interface
```

## 🚀 Quick Start Integration

### Step 1: Add Foundation Models Framework
In your Xcode project:
1. Select your target
2. Go to "Frameworks, Libraries, and Embedded Content"
3. Add `FoundationModels.framework`

### Step 2: Check Availability
Always check if Foundation Models is available:

```swift
import FoundationModels

let model = SystemLanguageModel.default

switch model.availability {
case .available:
    // Use AI features
    print("AI features ready!")
    
case .unavailable(.deviceNotEligible):
    // Show message about device requirements
    print("This device doesn't support Apple Intelligence")
    
case .unavailable(.appleIntelligenceNotEnabled):
    // Prompt user to enable in Settings
    print("Please enable Apple Intelligence in Settings")
    
case .unavailable(.modelNotReady):
    // Model is downloading
    print("AI model is downloading...")
    
case .unavailable(let reason):
    print("AI unavailable: \(reason)")
}
```

### Step 3: Implement Your Chosen Feature(s)

#### Option A: Start with AI Opponent (easiest)
```swift
@State private var aiOpponent = AIOpponent(difficulty: .medium)

func makeAIMove() async {
    do {
        let move = try await aiOpponent.calculateMove(for: board)
        board.makeMove(at: move)
    } catch {
        print("AI error: \(error)")
    }
}
```

#### Option B: Add Game Coach (high value)
```swift
@State private var coach = AIGameCoach(style: .intermediate)
@State private var advice: AIGameCoach.MoveAdvice?

Button("Get Hint") {
    Task {
        advice = try? await coach.provideAdvice(for: board)
    }
}

if let advice = advice {
    Text(advice.reasoning)
    Text("Try position \(advice.recommendedMove)")
}
```

#### Option C: Enhance with Commentary (fun factor)
```swift
@State private var commentator = AICommentator(style: .enthusiastic)
@State private var lastCommentary: String?

// After each move:
if let lastMove = board.moveHistory.last {
    let commentary = try await commentator.commentOnMove(
        lastMove,
        board: board,
        player: board.lastPlayer
    )
    lastCommentary = commentary.playByPlay
}
```

## 💡 MVP Recommendations

### For Quick Demo (1-2 features):
1. **AI Opponent** - Shows working AI, has fallback
2. **AI Commentary** - Makes it entertaining and unique

### For Full MVP (2-3 features):
1. **AI Opponent** - Core single-player experience
2. **AI Coach** - Helps users improve (educational value)
3. **Commentary** - Entertainment and personality

### For Innovative MVP (3-4 features):
1. **Natural Language Interface** - Unique selling point
2. **AI Opponent** - Play without touching screen
3. **Commentary** - Enhances voice-controlled experience
4. **Coach** - Optional help system

## 🎨 UI/UX Considerations

### Graceful Degradation
Always handle unavailability:
```swift
if !coach.isAvailable {
    Text("AI features require Apple Intelligence")
        .font(.caption)
        .foregroundStyle(.secondary)
}
```

### Loading States
AI responses take 1-3 seconds:
```swift
if isThinking {
    ProgressView("AI is thinking...")
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
}
```

### Error Handling
Network issues, model problems, etc:
```swift
do {
    let move = try await opponent.calculateMove(for: board)
} catch {
    // Fall back to simpler AI or show error
    print("Using fallback AI")
    let move = opponent.calculateFallbackMove(for: board)
}
```

## 📊 Performance Considerations

### Context Window Limits
- Foundation Models supports up to 4,096 tokens
- For tic-tac-toe, this is plenty (board state is tiny)
- Each session maintains conversation history

### Response Times
- Typical: 1-2 seconds per request
- Streaming: Updates every 0.1-0.3 seconds
- Shorter prompts = faster responses

### Memory Usage
- Each session maintains context
- Reset sessions periodically:
```swift
coach.reset()      // Clear history
opponent.reset()   // Clear learning data
```

## 🧪 Testing

### Test Without Apple Intelligence
All features include fallbacks or clear error states:
- AI Opponent: Uses rule-based fallback
- Coach/Commentary: Shows "unavailable" message
- Natural Language: Could fallback to pattern matching

### Test on Device
Foundation Models only works on device:
- Simulator: Will show "unavailable"
- Device with M1+: Should work
- iPhone 15 Pro+: Should work

### Unit Testing Example
```swift
import Testing

@Suite("AI Features Tests")
struct AITests {
    
    @Test("AI Coach availability")
    func testCoachAvailability() async throws {
        let coach = AIGameCoach()
        // Will be false in test environment
        #expect(!coach.isAvailable)
    }
    
    @Test("AI Opponent fallback works")
    func testOpponentFallback() async throws {
        let opponent = AIOpponent(difficulty: .easy)
        var board = GameBoard()
        
        // Should work even without Foundation Models
        let move = try await opponent.calculateMove(for: board)
        #expect((0..<9).contains(move))
        #expect(board.player(at: move) == nil)
    }
}
```

## 🔐 Privacy & App Store

### Privacy Benefits
- All processing happens on-device
- No data sent to cloud
- No API keys to manage
- Complies with Apple's privacy standards

### App Store Requirements
- Mention "Requires Apple Intelligence" in description
- Handle unavailability gracefully
- Don't make AI features mandatory (some devices don't support)

### Info.plist (if needed)
```xml
<key>NSAppleEventsUsageDescription</key>
<string>We use on-device AI to provide game coaching and commentary</string>
```

## 🚢 Deployment Strategy

### Phase 1: Soft Launch
- Implement AI Opponent with fallback
- Test on beta users with various devices

### Phase 2: Enhanced Features
- Add AI Coach for premium users
- Collect feedback on usefulness

### Phase 3: Full AI Experience
- Add Commentary for entertainment
- Natural Language as accessibility feature

## 📱 Device Compatibility

### Supported (Apple Intelligence Available)
- iPhone 15 Pro, 15 Pro Max
- iPhone 16, 16 Plus, 16 Pro, 16 Pro Max
- iPad with M1 or later
- Mac with M1 or later

### Partially Supported (Fallback AI)
- iPhone 14 and earlier
- iPad with A-series chips
- Intel Macs

## 🎓 Learning Resources

### WWDC Videos
- "What's new in Foundation Models" (WWDC 2025)
- "Adopting Foundation Models in your app" (WWDC 2025)

### Apple Documentation
- [Foundation Models Framework](https://developer.apple.com/documentation/FoundationModels)
- [Guided Generation Guide](https://developer.apple.com/documentation/FoundationModels/generating-swift-data-structures-with-guided-generation)
- [Tool Calling Guide](https://developer.apple.com/documentation/FoundationModels/expanding-generation-with-tool-calling)

## 🤝 Support

### Common Issues

**"Model unavailable" error:**
- Check device compatibility
- Verify Apple Intelligence is enabled in Settings
- Ensure iOS/macOS is up to date

**Slow responses:**
- Simplify prompts
- Reduce instruction length
- Reset sessions to clear context

**Invalid moves from AI:**
- Validate all AI suggestions
- Fall back to rule-based AI
- Add constraints in prompts

## 🎯 Next Steps

1. Choose 1-2 features for MVP
2. Implement with availability checks
3. Test on compatible devices
4. Add fallbacks for unsupported devices
5. Polish UI/UX around loading states
6. Submit to TestFlight for feedback

---

**Pro Tip:** Start with AI Opponent - it has the highest impact-to-effort ratio and includes a working fallback for all devices!
