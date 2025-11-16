//
//  ComponentQuickReference.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

/*
 COMPONENT QUICK REFERENCE
 =========================
 
 This file provides quick examples of how to use each refactored component.
 It's not meant to be compiled - it's a reference document in Swift syntax.
 
 
 ## GameBoard - Pure Game Logic
 
 ```swift
 var board = GameBoard()
 
 // Make moves
 board.makeMove(at: 0)  // X at top-left
 board.makeMove(at: 4)  // O at center
 
 // Check game state
 if let winner = board.winner {
     print("Winner: \(winner.symbol)")
 }
 
 if board.isDraw {
     print("Game is a draw")
 }
 
 if board.isGameOver {
     print("Game has ended")
 }
 
 // Get winning line for visualization
 if let line = board.winningLine {
     print("Winning line: \(line.startCell) to \(line.endCell)")
 }
 
 // Reset the game
 board.reset()
 ```
 
 
 ## GridLayout - Layout Calculations
 
 ```swift
 let layout = GridLayout(
     frame: CGRect(x: 0, y: 0, width: 500, height: 500),
     scaleFactor: 0.85,
     dimension: 3
 )
 
 // Get cell size
 let size = layout.cellSize  // CGSize
 
 // Get grid origin (bottom-left corner)
 let origin = layout.gridOrigin  // CGPoint
 
 // Get total grid size
 let totalSize = layout.gridSize  // CGFloat
 
 // Convert cell index to scene position
 let position = layout.position(for: 4)  // Center cell position
 
 // Convert scene point to cell index
 if let index = layout.cellIndex(at: CGPoint(x: 250, y: 250)) {
     print("Tapped cell \(index)")
 }
 ```
 
 
 ## GridRenderer - Grid Line Rendering
 
 ```swift
 let renderer = GridRenderer(
     scene: myScene,
     scaleFactor: 0.85,
     dimension: 3,
     lineWidth: 2.0
 )
 
 // Render the grid
 renderer.render(in: myScene.frame)
 
 // Fade grid lines (e.g., when game ends)
 renderer.fade(to: 0.25, duration: 0.3)
 
 // Restore grid to full opacity
 renderer.restore()
 ```
 
 
 ## MarkRenderer - Player Mark Rendering
 
 ```swift
 let renderer = MarkRenderer(
     scene: myScene,
     fontScale: 0.65,
     animationDuration: 0.15
 )
 
 // Place a mark with animation
 renderer.placeMark(
     "X",
     at: 0,
     position: CGPoint(x: 100, y: 100),
     cellSize: CGSize(width: 150, height: 150)
 )
 
 // Relayout marks after scene resize
 renderer.relayout(using: layout)
 
 // Clear all marks
 renderer.clear()
 ```
 
 
 ## WinningLineAnimator - Win Animation
 
 ```swift
 let animator = WinningLineAnimator(
     scene: myScene,
     lineWidth: 8,
     glowWidth: 16
 )
 
 // Show winning line with animation
 animator.showWinningLine(
     from: CGPoint(x: 50, y: 50),
     to: CGPoint(x: 450, y: 450)
 )
 
 // Remove winning line
 animator.removeWinningLine()
 ```
 
 
 ## GameScene - Main Coordinator
 
 The refactored GameScene is much simpler and delegates to components:
 
 ```swift
 class GameScene: SKScene {
     private lazy var gridRenderer = GridRenderer(scene: self)
     private lazy var markRenderer = MarkRenderer(scene: self)
     private lazy var winningLineAnimator = WinningLineAnimator(scene: self)
     private var board = GameBoard()
     
     private var gridLayout: GridLayout {
         GridLayout(frame: frame, scaleFactor: 0.85, dimension: 3)
     }
     
     override func didMove(to view: SKView) {
         gridRenderer.render(in: frame)
         updateStatusLabel()
     }
     
     override func didChangeSize(_ oldSize: CGSize) {
         gridRenderer.render(in: frame)
         markRenderer.relayout(using: gridLayout)
     }
     
     private func placeMark(at cellIndex: Int) {
         let layout = gridLayout
         markRenderer.placeMark(
             board.lastPlayer.symbol,
             at: cellIndex,
             position: layout.position(for: cellIndex),
             cellSize: layout.cellSize
         )
         
         if board.isGameOver {
             handleGameOver()
         }
     }
     
     private func handleGameOver() {
         if let line = board.winningLine {
             let layout = gridLayout
             winningLineAnimator.showWinningLine(
                 from: layout.position(for: line.startCell),
                 to: layout.position(for: line.endCell)
             )
             gridRenderer.fade(to: 0.25, duration: 0.3)
         }
     }
     
     private func resetGame() {
         board.reset()
         markRenderer.clear()
         winningLineAnimator.removeWinningLine()
         gridRenderer.restore()
     }
 }
 ```
 
 
 ## Testing with GameBoardTests
 
 ```swift
 import Testing
 @testable import tictactoe
 
 @Suite("My Custom Tests")
 struct MyGameTests {
     
     @Test("Custom game scenario")
     func customScenario() {
         var board = GameBoard()
         
         // Set up a specific game state
         board.makeMove(at: 0)  // X
         board.makeMove(at: 3)  // O
         board.makeMove(at: 1)  // X
         
         // Verify expectations
         #expect(board.currentPlayer == .o)
         #expect(board.winner == nil)
         #expect(!board.isGameOver)
     }
 }
 ```
 
 
 ## Configuration Customization
 
 To customize the game appearance, modify the Configuration struct:
 
 ```swift
 private struct Configuration {
     static let gridScaleFactor: CGFloat = 0.9  // Make grid larger
     static let gridDimension = 3
     static let statusLabelSpacing: CGFloat = 80  // More spacing
     static let statusFontSize: CGFloat = 28  // Larger font
     static let markFontScale: CGFloat = 0.7  // Larger marks
     static let gridLineWidth: CGFloat = 3  // Thicker lines
     static let winLineWidth: CGFloat = 10  // Thicker win line
     static let winLineGlowWidth: CGFloat = 20  // More glow
     static let gridFadeAlpha: CGFloat = 0.15  // More fade
     static let markAnimationDuration: TimeInterval = 0.2  // Slower animation
     static let fadeAnimationDuration: TimeInterval = 0.4  // Slower fade
 }
 ```
 
 
 ## Adding a 4x4 Grid
 
 To extend the game to support larger grids:
 
 1. Update GameBoard.winningPatterns for 4x4 patterns
 2. Change Configuration.gridDimension to 4
 3. No changes needed to renderers - they're dimension-agnostic!
 
 
 ## Creating Custom Themes
 
 To create themed variations:
 
 ```swift
 // Neon Theme
 class NeonGridRenderer: GridRenderer {
     override func createLine(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
         let line = super.createLine(from: start, to: end)
         line.strokeColor = .cyan
         line.glowWidth = 10
         return line
     }
 }
 
 // Use in GameScene
 private lazy var gridRenderer = NeonGridRenderer(scene: self)
 ```
 
 
 ## Performance Tips
 
 1. GridLayout is a struct - it's cheap to create repeatedly
 2. Renderers use weak scene references - no retain cycles
 3. GameBoard uses bitmasks - very fast win detection
 4. Lazy initialization - components created only when needed
 5. Components are stateful - avoid recreating unnecessarily
 
 
 ## Common Patterns
 
 ### Pattern 1: Coordinating Multiple Renderers
 ```swift
 private func updateGameState() {
     let layout = gridLayout
     
     // Update all renderers with same layout
     gridRenderer.render(in: frame)
     markRenderer.relayout(using: layout)
     layoutStatusLabel()
 }
 ```
 
 ### Pattern 2: Handling Game State Changes
 ```swift
 private func afterMove() {
     updateStatusLabel()
     
     if board.isGameOver {
         handleGameOver()
     }
 }
 ```
 
 ### Pattern 3: Full Reset Flow
 ```swift
 private func fullReset() {
     // 1. Reset model
     board.reset()
     
     // 2. Clear visuals
     markRenderer.clear()
     winningLineAnimator.removeWinningLine()
     
     // 3. Restore UI
     gridRenderer.restore()
     updateStatusLabel()
 }
 ```
 
 
 ## Architecture Diagram
 
 ```
 User Input
     ↓
 GameScene (Coordinator)
     ↓
     ├─→ GameBoard (validates move, updates state)
     ├─→ GridLayout (calculates positions)
     ├─→ MarkRenderer (draws X or O)
     └─→ if game over
         ├─→ WinningLineAnimator (shows winning line)
         └─→ GridRenderer (fades grid)
 ```
 
 
 ## Component Dependencies
 
 ```
 GameScene
 ├── depends on → GameBoard (model)
 ├── depends on → GridLayout (calculations)
 ├── depends on → GridRenderer (weak scene ref)
 ├── depends on → MarkRenderer (weak scene ref)
 └── depends on → WinningLineAnimator (weak scene ref)
 
 GridLayout
 └── no dependencies (pure calculations)
 
 GameBoard
 └── no dependencies (pure game logic)
 
 All Renderers
 └── depend on → SKScene (weak reference)
 ```
 
 
 ## Thread Safety
 
 - GameBoard: Value type (struct) - automatically thread-safe per instance
 - GridLayout: Value type (struct) - automatically thread-safe per instance
 - Renderers: Should only be accessed from main thread (SpriteKit requirement)
 - GameScene: Should only be accessed from main thread (SpriteKit requirement)
 
 
 ## Memory Management
 
 - Renderers use weak scene references → no retain cycles
 - GameBoard is a value type → no reference counting
 - GridLayout is a value type → no reference counting
 - Lazy properties → created only when first accessed
 - All nodes properly removed when clearing → no memory leaks
 
 */
