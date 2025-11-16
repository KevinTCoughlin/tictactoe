//
//  GameScene.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/2/25.
//

import SpriteKit

/// The main game scene for tic-tac-toe, handling rendering and user interaction.
///
/// This scene manages the visual representation of the game board, including
/// the grid lines, player marks (X and O), status text, and winning line animations.
/// It responds to touch/mouse input and updates the display as the game progresses.
final class GameScene: SKScene {
    
    // MARK: - Constants
    
    /// The scaling factor for the grid relative to the scene size.
    private static let gridScaleFactor: CGFloat = 0.85
    
    /// The number of rows/columns in the tic-tac-toe grid.
    private static let gridDimension = 3
    
    /// The vertical spacing between the grid and status label.
    private static let statusLabelSpacing: CGFloat = 60
    
    /// Font size for the status label.
    private static let statusFontSize: CGFloat = 24
    
    /// Font scale for player marks relative to cell size.
    private static let markFontScale: CGFloat = 0.65
    
    /// Line width for the grid.
    private static let gridLineWidth: CGFloat = 2
    
    /// Line width for the winning line.
    private static let winLineWidth: CGFloat = 8
    
    /// Inner glow width for the winning line.
    private static let winLineGlowWidth: CGFloat = 16
    
    /// Alpha value for faded grid lines after a win.
    private static let gridFadeAlpha: CGFloat = 0.25
    
    /// Node name identifier for winning line shapes.
    private static let winLineNodeName = "winLine"
    
    /// Corner radius for rounded corners.
    private static let cornerRadius: CGFloat = 20
    
    /// Animation duration for mark appearance.
    private static let markAnimationDuration: TimeInterval = 0.15
    
    /// Animation duration for fade effects.
    private static let fadeAnimationDuration: TimeInterval = 0.3
    
    // MARK: - Scene Nodes
    
    /// The grid lines forming the tic-tac-toe board.
    private var gridLines: [SKShapeNode] = []
    
    /// Dictionary mapping cell indices to their corresponding mark labels.
    private var marks: [Int: SKLabelNode] = [:]
    
    /// Label displaying current game status (turn, winner, or draw).
    private lazy var statusLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Semibold")
        label.fontSize = Self.statusFontSize
        label.fontColor = .label
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .top
        return label
    }()
    
    // MARK: - Game State
    
    /// The underlying game board model.
    private var board = GameBoard()
    
    // MARK: - Layout Computed Properties
    
    /// The size of each cell in the grid.
    private var cellSize: CGSize {
        let minSide = min(size.width, size.height)
        let gridSize = minSide * Self.gridScaleFactor
        let cellDimension = gridSize / CGFloat(Self.gridDimension)
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    /// The origin point (bottom-left corner) of the grid.
    private var gridOrigin: CGPoint {
        let totalGridSize = cellSize.width * CGFloat(Self.gridDimension)
        return CGPoint(
            x: frame.midX - totalGridSize / 2,
            y: frame.midY - totalGridSize / 2
        )
    }
    
    /// The total size of the grid.
    private var gridSize: CGFloat {
        cellSize.width * CGFloat(Self.gridDimension)
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        relayoutScene()
    }
    
    // MARK: - Scene Setup
    
    /// Performs initial setup of the scene.
    private func setupScene() {
        // Use system background color for better platform integration
        #if os(iOS) || os(tvOS)
        backgroundColor = .systemBackground
        #else
        backgroundColor = .windowBackgroundColor
        #endif
        
        addChild(statusLabel)
        drawGrid()
        updateStatusLabel()
        layoutStatusLabel()
    }
    
    /// Re-layouts all scene elements after a size change.
    private func relayoutScene() {
        removeGrid()
        drawGrid()
        relayoutMarks()
        layoutStatusLabel()
    }
    
    // MARK: - Status Label
    
    /// Positions the status label above the grid.
    private func layoutStatusLabel() {
        statusLabel.position = CGPoint(
            x: frame.midX,
            y: gridOrigin.y + gridSize + Self.statusLabelSpacing
        )
    }
    
    /// Updates the status label text based on current game state.
    private func updateStatusLabel() {
        statusLabel.text = statusText
    }
    
    /// The text to display in the status label based on game state.
    private var statusText: String {
        if let winner = board.winner {
            return "Winner: \(winner.symbol) — tap to reset"
        } else if board.isDraw {
            return "Draw — tap to reset"
        } else {
            return "Turn: \(board.currentPlayer.symbol)"
        }
    }
    
    // MARK: - Grid Drawing
    
    /// Draws the tic-tac-toe grid lines.
    private func drawGrid() {
        drawVerticalGridLines()
        drawHorizontalGridLines()
    }
    
    /// Draws the two vertical grid lines.
    private func drawVerticalGridLines() {
        for i in 1..<Self.gridDimension {
            let line = createVerticalGridLine(at: i)
            addChild(line)
            gridLines.append(line)
        }
    }
    
    /// Creates a vertical grid line at the specified column index.
    private func createVerticalGridLine(at columnIndex: Int) -> SKShapeNode {
        let path = CGMutablePath()
        let x = gridOrigin.x + CGFloat(columnIndex) * cellSize.width
        let startPoint = CGPoint(x: x, y: gridOrigin.y)
        let endPoint = CGPoint(x: x, y: gridOrigin.y + gridSize)
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        return createGridLineNode(path: path)
    }
    
    /// Draws the two horizontal grid lines.
    private func drawHorizontalGridLines() {
        for i in 1..<Self.gridDimension {
            let line = createHorizontalGridLine(at: i)
            addChild(line)
            gridLines.append(line)
        }
    }
    
    /// Creates a horizontal grid line at the specified row index.
    private func createHorizontalGridLine(at rowIndex: Int) -> SKShapeNode {
        let path = CGMutablePath()
        let y = gridOrigin.y + CGFloat(rowIndex) * cellSize.height
        let startPoint = CGPoint(x: gridOrigin.x, y: y)
        let endPoint = CGPoint(x: gridOrigin.x + gridSize, y: y)
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        return createGridLineNode(path: path)
    }
    
    /// Creates a styled shape node for a grid line.
    private func createGridLineNode(path: CGPath) -> SKShapeNode {
        let line = SKShapeNode(path: path)
        line.strokeColor = .separator
        line.lineWidth = Self.gridLineWidth
        line.lineCap = .round
        return line
    }
    
    /// Removes all grid lines from the scene.
    private func removeGrid() {
        gridLines.forEach { $0.removeFromParent() }
        gridLines.removeAll()
    }
    
    // MARK: - Mark Rendering
    
    /// Re-positions all existing marks after a layout change.
    private func relayoutMarks() {
        marks.forEach { cellIndex, markNode in
            markNode.position = position(for: cellIndex)
        }
    }
    
    /// Places a mark (X or O) at the specified cell index with animation.
    private func placeMark(at cellIndex: Int) {
        let markLabel = createMarkLabel(at: cellIndex)
        marks[cellIndex] = markLabel
        addChild(markLabel)
        animateMark(markLabel)
        
        // Play turn sound
        SoundManager.shared.playTurn()
        
        if board.isGameOver {
            handleGameOver()
        }
    }
    
    /// Creates a label node for displaying a player mark.
    private func createMarkLabel(at cellIndex: Int) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Bold")
        label.fontSize = cellSize.width * Self.markFontScale
        label.fontColor = .label
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = board.lastPlayer.symbol
        label.position = position(for: cellIndex)
        label.setScale(0.1)
        label.alpha = 0
        return label
    }
    
    /// Animates a mark with a smooth spring-like scale and fade effect.
    private func animateMark(_ markNode: SKLabelNode) {
        let fadeIn = SKAction.fadeIn(withDuration: Self.markAnimationDuration)
        let scaleUp = SKAction.scale(to: 1.15, duration: Self.markAnimationDuration)
        scaleUp.timingMode = .easeOut
        
        let scaleDown = SKAction.scale(to: 1.0, duration: Self.markAnimationDuration)
        scaleDown.timingMode = .easeInEaseOut
        
        let appearGroup = SKAction.group([fadeIn, scaleUp])
        let sequence = SKAction.sequence([appearGroup, scaleDown])
        
        markNode.run(sequence)
    }
    
    /// Handles visual updates when the game ends.
    private func handleGameOver() {
        if let winLine = createWinningLineShape() {
            addChild(winLine)
            fadeGridLines()
            
            // Play winning sound
            SoundManager.shared.playWin()
        } else if board.isDraw {
            // Play draw sound
            SoundManager.shared.playDraw()
        }
    }
    
    /// Fades the grid lines to highlight the winning line.
    private func fadeGridLines() {
        let fadeAction = SKAction.fadeAlpha(to: Self.gridFadeAlpha, duration: Self.fadeAnimationDuration)
        fadeAction.timingMode = .easeInEaseOut
        gridLines.forEach { $0.run(fadeAction) }
    }
    
    // MARK: - Coordinate Conversion
    
    /// Returns the scene position for a given cell index.
    private func position(for cellIndex: Int) -> CGPoint {
        let row = cellIndex / Self.gridDimension
        let column = cellIndex % Self.gridDimension
        
        return CGPoint(
            x: gridOrigin.x + CGFloat(column) * cellSize.width + cellSize.width / 2,
            y: gridOrigin.y + CGFloat(row) * cellSize.height + cellSize.height / 2
        )
    }
    
    /// Returns the cell index for a given point in scene coordinates, if valid.
    private func cellIndex(at point: CGPoint) -> Int? {
        guard isPointInGrid(point) else { return nil }
        
        let column = Int((point.x - gridOrigin.x) / cellSize.width)
        let row = Int((point.y - gridOrigin.y) / cellSize.height)
        let index = row * Self.gridDimension + column
        
        guard (0..<9).contains(index) else { return nil }
        return index
    }
    
    /// Returns `true` if the point is within the grid bounds.
    private func isPointInGrid(_ point: CGPoint) -> Bool {
        let gridMaxX = gridOrigin.x + gridSize
        let gridMaxY = gridOrigin.y + gridSize
        
        return point.x >= gridOrigin.x && point.x <= gridMaxX &&
               point.y >= gridOrigin.y && point.y <= gridMaxY
    }
    
    // MARK: - Input Handling
    
    #if os(iOS) || os(tvOS)
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTap(at: touch.location(in: self))
    }
    #endif
    
    #if os(OSX)
    override func mouseUp(with event: NSEvent) {
        handleTap(at: event.location(in: self))
    }
    #endif
    
    /// Handles tap/click input at the specified location.
    private func handleTap(at location: CGPoint) {
        if board.isGameOver {
            resetGame()
        } else {
            attemptMove(at: location)
        }
    }
    
    /// Attempts to make a move at the tapped location.
    private func attemptMove(at location: CGPoint) {
        guard let cellIndex = cellIndex(at: location) else { return }
        guard board.makeMove(at: cellIndex) else { return }
        
        placeMark(at: cellIndex)
        updateStatusLabel()
    }
    
    // MARK: - Game Reset
    
    /// Resets the game to its initial state.
    private func resetGame() {
        board.reset()
        removeAllMarks()
        removeWinningLine()
        restoreGridLines()
        updateStatusLabel()
        
        // Play reset sound
        SoundManager.shared.playReset()
        
        // Increment ad counter and potentially show an ad (only if SDK available)
        #if os(iOS) && canImport(GoogleMobileAds)
        if let viewController = view?.window?.rootViewController {
            AdManager.shared.incrementGameCounter(from: viewController)
        }
        #endif
    }
    
    /// Removes all player marks from the scene.
    private func removeAllMarks() {
        marks.values.forEach { $0.removeFromParent() }
        marks.removeAll()
    }
    
    /// Removes the winning line from the scene, if present.
    private func removeWinningLine() {
        children
            .filter { $0.name == Self.winLineNodeName }
            .forEach { $0.removeFromParent() }
    }
    
    /// Restores grid lines to full opacity.
    private func restoreGridLines() {
        gridLines.forEach { $0.alpha = 1.0 }
    }
    
    // MARK: - Winning Line
    
    /// Creates a node for the winning line with modern layered effects.
    private func createWinningLineShape() -> SKNode? {
        guard let line = board.winningLine else { return nil }
        
        let startPosition = position(for: line.startCell)
        let endPosition = position(for: line.endCell)
        
        // Create container for layered effects
        let container = SKNode()
        container.name = Self.winLineNodeName
        
        // Layer 1: Outer glow (subtle, wider)
        let outerGlowPath = CGMutablePath()
        outerGlowPath.move(to: startPosition)
        outerGlowPath.addLine(to: endPosition)
        
        let outerGlow = SKShapeNode(path: outerGlowPath)
        outerGlow.strokeColor = .systemBlue.withAlphaComponent(0.2)
        outerGlow.lineWidth = Self.winLineGlowWidth * 1.5
        outerGlow.lineCap = .round
        outerGlow.glowWidth = 20
        outerGlow.alpha = 0
        container.addChild(outerGlow)
        
        // Layer 2: Inner glow (brighter, medium)
        let innerGlowPath = CGMutablePath()
        innerGlowPath.move(to: startPosition)
        innerGlowPath.addLine(to: endPosition)
        
        let innerGlow = SKShapeNode(path: innerGlowPath)
        innerGlow.strokeColor = .systemBlue.withAlphaComponent(0.5)
        innerGlow.lineWidth = Self.winLineGlowWidth
        innerGlow.lineCap = .round
        innerGlow.glowWidth = 12
        innerGlow.alpha = 0
        container.addChild(innerGlow)
        
        // Layer 3: Core line (solid, vibrant)
        let corePath = CGMutablePath()
        corePath.move(to: startPosition)
        corePath.addLine(to: endPosition)
        
        let coreLine = SKShapeNode(path: corePath)
        coreLine.strokeColor = .white
        coreLine.lineWidth = Self.winLineWidth
        coreLine.lineCap = .round
        coreLine.glowWidth = 6
        coreLine.alpha = 0
        container.addChild(coreLine)
        
        // Animate the winning line with a modern "draw" effect
        animateWinningLine(container: container, from: startPosition, to: endPosition)
        
        // Add pulsing animation for emphasis
        addPulsingAnimation(to: container)
        
        return container
    }
    
    /// Animates the winning line with a drawing effect and fade-in.
    private func animateWinningLine(container: SKNode, from startPosition: CGPoint, to endPosition: CGPoint) {
        guard let outerGlow = container.children[0] as? SKShapeNode,
              let innerGlow = container.children[1] as? SKShapeNode,
              let coreLine = container.children[2] as? SKShapeNode else { return }
        
        // Create a drawing animation using strokeEnd
        let drawDuration: TimeInterval = 0.5
        
        // Animate each layer with slight delays for depth effect
        animateStrokeDraw(outerGlow, duration: drawDuration, delay: 0.0)
        animateStrokeDraw(innerGlow, duration: drawDuration, delay: 0.05)
        animateStrokeDraw(coreLine, duration: drawDuration, delay: 0.1)
        
        // Fade in all layers
        let fadeIn = SKAction.fadeIn(withDuration: drawDuration * 0.3)
        fadeIn.timingMode = .easeIn
        
        outerGlow.run(fadeIn)
        innerGlow.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.05),
            fadeIn
        ]))
        coreLine.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            fadeIn
        ]))
    }
    
    /// Animates the stroke drawing effect for a shape node.
    private func animateStrokeDraw(_ shapeNode: SKShapeNode, duration: TimeInterval, delay: TimeInterval) {
        // Create a custom action to animate strokeEnd
        let drawAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let progress = elapsedTime / duration
            // Use ease-out timing for smoother drawing
            let easedProgress = 1 - pow(1 - progress, 3)
            
            if let shape = node as? SKShapeNode {
                // Simulate stroke drawing by revealing the line progressively
                // Note: SpriteKit doesn't have direct strokeEnd, so we use alpha ramp
                shape.alpha = min(1.0, easedProgress * 1.5)
            }
        }
        
        drawAction.timingMode = .easeOut
        
        if delay > 0 {
            shapeNode.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                drawAction
            ]))
        } else {
            shapeNode.run(drawAction)
        }
    }
    
    /// Adds a subtle pulsing animation to emphasize the winning line.
    private func addPulsingAnimation(to container: SKNode) {
        // Wait for the draw animation to complete
        let waitAction = SKAction.wait(forDuration: 0.6)
        
        // Create a gentle pulse effect
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.8)
        scaleUp.timingMode = .easeInEaseOut
        
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        scaleDown.timingMode = .easeInEaseOut
        
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        container.run(SKAction.sequence([waitAction, repeatPulse]))
    }
}

// MARK: - Game Model

/// Represents a player in the tic-tac-toe game.
enum Player {
    case x
    case o
    
    /// Returns the opposite player.
    var opponent: Player {
        self == .x ? .o : .x
    }
    
    /// Returns the display symbol for this player.
    var symbol: String {
        self == .x ? "X" : "O"
    }
}

/// A tic-tac-toe game board using efficient bitmask representation.
///
/// The board uses 9-bit masks to track each player's moves, where each bit
/// corresponds to a cell in row-major order (0-8). This allows for fast
/// win detection and minimal memory usage.
///
/// Board layout:
/// ```
/// 0 | 1 | 2
/// ---------
/// 3 | 4 | 5
/// ---------
/// 6 | 7 | 8
/// ```
struct GameBoard {
    
    // MARK: - Types
    
    /// Represents a winning pattern with its bitmask and visual endpoints.
    typealias WinningPattern = (mask: Int, startCell: Int, endCell: Int)
    
    // MARK: - State
    
    /// Bitmask representing X player's occupied cells.
    private(set) var xMask: Int = 0
    
    /// Bitmask representing O player's occupied cells.
    private(set) var oMask: Int = 0
    
    /// The player whose turn it is to move.
    private(set) var currentPlayer: Player = .x
    
    /// The player who made the most recent move.
    private(set) var lastPlayer: Player = .x
    
    // MARK: - Constants
    
    /// All possible winning patterns for a 3×3 board with their visual endpoints.
    ///
    /// Each pattern consists of a bitmask representing the three cells that form
    /// a winning line, along with the start and end cell indices for drawing.
    static let winningPatterns: [WinningPattern] = [
        // Rows
        (mask: 0b111_000_000, startCell: 0, endCell: 2),
        (mask: 0b000_111_000, startCell: 3, endCell: 5),
        (mask: 0b000_000_111, startCell: 6, endCell: 8),
        // Columns
        (mask: 0b100_100_100, startCell: 0, endCell: 6),
        (mask: 0b010_010_010, startCell: 1, endCell: 7),
        (mask: 0b001_001_001, startCell: 2, endCell: 8),
        // Diagonals
        (mask: 0b100_010_001, startCell: 0, endCell: 8),
        (mask: 0b001_010_100, startCell: 2, endCell: 6)
    ]
    
    /// Bitmask representing all nine cells occupied.
    private static let fullBoardMask = 0b111_111_111
    
    // MARK: - Computed Properties
    
    /// A bitmask of all occupied cells (both X and O).
    var occupiedMask: Int {
        xMask | oMask
    }
    
    /// The winning player, if any.
    ///
    /// Returns `.x` or `.o` if that player has achieved a winning pattern,
    /// or `nil` if no player has won yet.
    var winner: Player? {
        for pattern in Self.winningPatterns {
            if hasWinningPattern(mask: xMask, pattern: pattern.mask) {
                return .x
            }
            if hasWinningPattern(mask: oMask, pattern: pattern.mask) {
                return .o
            }
        }
        return nil
    }
    
    /// Returns `true` if the game is a draw (board full with no winner).
    var isDraw: Bool {
        occupiedMask == Self.fullBoardMask && winner == nil
    }
    
    /// Returns `true` if the game has ended (either won or drawn).
    var isGameOver: Bool {
        winner != nil || isDraw
    }
    
    /// The winning line's start and end cell indices, if any.
    ///
    /// Returns a tuple of (startCell, endCell) if there's a winning line,
    /// or `nil` if no player has won yet.
    var winningLine: (startCell: Int, endCell: Int)? {
        for pattern in Self.winningPatterns {
            if hasWinningPattern(mask: xMask, pattern: pattern.mask) ||
               hasWinningPattern(mask: oMask, pattern: pattern.mask) {
                return (pattern.startCell, pattern.endCell)
            }
        }
        return nil
    }
    
    // MARK: - Public Methods
    
    /// Attempts to place a mark for the current player at the specified cell.
    ///
    /// - Parameter index: The cell index (0-8) where the current player wants to move.
    /// - Returns: `true` if the move was legal and applied, `false` otherwise.
    ///
    /// A move is illegal if:
    /// - The index is out of bounds (not 0-8)
    /// - The cell is already occupied
    /// - The game is already over
    @discardableResult
    mutating func makeMove(at index: Int) -> Bool {
        guard isValidIndex(index) else { return false }
        guard isCellEmpty(at: index) else { return false }
        guard !isGameOver else { return false }
        
        updateMask(for: currentPlayer, at: index)
        advanceTurn()
        
        return true
    }
    
    /// Resets the board to its initial state.
    ///
    /// Clears all moves and sets the current player back to X.
    mutating func reset() {
        xMask = 0
        oMask = 0
        currentPlayer = .x
        lastPlayer = .x
    }
    
    // MARK: - Private Helpers
    
    /// Returns `true` if the given player mask matches the winning pattern.
    private func hasWinningPattern(mask: Int, pattern: Int) -> Bool {
        (mask & pattern) == pattern
    }
    
    /// Returns `true` if the index is within valid bounds (0-8).
    private func isValidIndex(_ index: Int) -> Bool {
        (0..<9).contains(index)
    }
    
    /// Returns `true` if the cell at the given index is unoccupied.
    private func isCellEmpty(at index: Int) -> Bool {
        let cellBit = bitMask(for: index)
        return (occupiedMask & cellBit) == 0
    }
    
    /// Returns the bitmask for a given cell index.
    ///
    /// Cell 0 maps to bit 8, cell 8 maps to bit 0 (reverse order for readability).
    private func bitMask(for index: Int) -> Int {
        1 << (8 - index)
    }
    
    /// Updates the appropriate player mask with the given move.
    private mutating func updateMask(for player: Player, at index: Int) {
        let cellBit = bitMask(for: index)
        switch player {
        case .x: xMask |= cellBit
        case .o: oMask |= cellBit
        }
    }
    
    /// Advances to the next turn by swapping players.
    private mutating func advanceTurn() {
        lastPlayer = currentPlayer
        currentPlayer = currentPlayer.opponent
    }
}
