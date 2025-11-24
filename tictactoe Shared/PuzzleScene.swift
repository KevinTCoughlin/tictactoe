//
//  PuzzleScene.swift
//  tictactoe Shared
//
//  Created by GitHub Copilot on 11/24/25.
//

import SpriteKit

/// A scene for presenting and solving tic-tac-toe puzzles.
///
/// This scene extends the basic game scene with puzzle-specific features:
/// - Instruction display
/// - Solution validation
/// - Hint system
/// - Success/failure feedback
/// - Performance timing
final class PuzzleScene: SKScene {
    
    // MARK: - Configuration
    
    private struct Configuration {
        static let gridScaleFactor: CGFloat = 0.7
        static let gridDimension = 3
        static let instructionFontSize: CGFloat = 20
        static let hintFontSize: CGFloat = 16
        static let feedbackFontSize: CGFloat = 28
        static let statusFontSize: CGFloat = 18
        static let buttonFontSize: CGFloat = 20
        static let spacing: CGFloat = 20
        static let gridLineWidth: CGFloat = 2
        static let markFontScale: CGFloat = 0.65
        static let successColor: SKColor = .systemGreen
        static let failureColor: SKColor = .systemRed
        static let hintColor: SKColor = .systemOrange
        static let animationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Components
    
    private lazy var gridRenderer = GridRenderer(
        scene: self,
        scaleFactor: Configuration.gridScaleFactor,
        dimension: Configuration.gridDimension,
        lineWidth: Configuration.gridLineWidth
    )
    
    private lazy var markRenderer = MarkRenderer(
        scene: self,
        fontScale: Configuration.markFontScale,
        animationDuration: Configuration.animationDuration
    )
    
    // MARK: - UI Elements
    
    private lazy var instructionLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Semibold")
        label.fontSize = Configuration.instructionFontSize
        label.fontColor = .label
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .top
        return label
    }()
    
    private lazy var hintLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFont")
        label.fontSize = Configuration.hintFontSize
        label.fontColor = Configuration.hintColor
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .top
        label.alpha = 0 // Hidden by default
        return label
    }()
    
    private lazy var feedbackLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Bold")
        label.fontSize = Configuration.feedbackFontSize
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var statusLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFont")
        label.fontSize = Configuration.statusFontSize
        label.fontColor = .secondaryLabel
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .bottom
        return label
    }()
    
    private lazy var hintButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Semibold")
        label.fontSize = Configuration.buttonFontSize
        label.fontColor = .systemBlue
        label.text = "💡 Hint"
        label.name = "hintButton"
        return label
    }()
    
    private lazy var resetButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Semibold")
        label.fontSize = Configuration.buttonFontSize
        label.fontColor = .systemBlue
        label.text = "↻ Reset"
        label.name = "resetButton"
        return label
    }()
    
    private lazy var nextPuzzleButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Semibold")
        label.fontSize = Configuration.buttonFontSize
        label.fontColor = .systemBlue
        label.text = "Next →"
        label.name = "nextPuzzleButton"
        label.alpha = 0
        return label
    }()
    
    // MARK: - State
    
    /// Current puzzle being solved
    private var currentPuzzle: GamePuzzle?
    
    /// Current board state (modified as user makes moves)
    private var board: GameBoard?
    
    /// When the puzzle was started (for timing)
    private var startTime: Date?
    
    /// Current puzzle attempt
    private var currentAttempt: PuzzleAttempt?
    
    /// Whether puzzle has been completed
    private var isCompleted = false
    
    /// Number of hints shown for current puzzle
    private var hintsShown = 0
    
    /// Callback when puzzle is completed
    var onPuzzleCompleted: ((GamePuzzle, Bool, TimeInterval) -> Void)?
    
    /// Callback to load next puzzle
    var onNextPuzzle: (() -> Void)?
    
    // MARK: - Grid Layout
    
    private var gridLayout: GridLayout {
        GridLayout(
            frame: frame,
            scaleFactor: Configuration.gridScaleFactor,
            dimension: Configuration.gridDimension
        )
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        relayoutScene()
    }
    
    // MARK: - Scene Setup
    
    private func setupScene() {
        configureBackgroundColor()
        
        addChild(instructionLabel)
        addChild(hintLabel)
        addChild(feedbackLabel)
        addChild(statusLabel)
        addChild(hintButton)
        addChild(resetButton)
        addChild(nextPuzzleButton)
        
        gridRenderer.render(in: frame)
        layoutUI()
    }
    
    private func configureBackgroundColor() {
        #if os(iOS) || os(tvOS)
        backgroundColor = .systemBackground
        #else
        backgroundColor = .windowBackgroundColor
        #endif
    }
    
    private func relayoutScene() {
        gridRenderer.render(in: frame)
        markRenderer.relayout(using: gridLayout)
        layoutUI()
    }
    
    // MARK: - UI Layout
    
    private func layoutUI() {
        let layout = gridLayout
        let gridTop = layout.gridOrigin.y + layout.gridSize
        let gridBottom = layout.gridOrigin.y
        
        // Instruction at top
        instructionLabel.position = CGPoint(
            x: frame.midX,
            y: gridTop + Configuration.spacing * 3
        )
        
        // Hint below instruction
        hintLabel.position = CGPoint(
            x: frame.midX,
            y: instructionLabel.position.y - Configuration.spacing * 1.5
        )
        
        // Feedback in center of grid
        feedbackLabel.position = CGPoint(
            x: frame.midX,
            y: frame.midY
        )
        
        // Status below grid
        statusLabel.position = CGPoint(
            x: frame.midX,
            y: gridBottom - Configuration.spacing
        )
        
        // Buttons at bottom
        let buttonY = statusLabel.position.y - Configuration.spacing * 2
        hintButton.position = CGPoint(x: frame.midX - 80, y: buttonY)
        resetButton.position = CGPoint(x: frame.midX + 80, y: buttonY)
        nextPuzzleButton.position = CGPoint(x: frame.midX, y: buttonY)
    }
    
    // MARK: - Puzzle Presentation
    
    /// Presents a new puzzle to solve.
    func presentPuzzle(_ puzzle: GamePuzzle) {
        currentPuzzle = puzzle
        board = puzzle.board
        isCompleted = false
        hintsShown = 0
        startTime = Date()
        
        // Create attempt record
        let profile = PuzzleManager.shared.userProfile
        currentAttempt = PuzzleAttempt(
            puzzleId: puzzle.id,
            userDifficulty: profile.currentDifficulty
        )
        
        // Reset UI
        instructionLabel.text = puzzle.type.instruction
        hintLabel.alpha = 0
        hintLabel.text = puzzle.hint ?? ""
        feedbackLabel.alpha = 0
        nextPuzzleButton.alpha = 0
        hintButton.alpha = 1
        resetButton.alpha = 1
        
        // Update status
        updateStatus()
        
        // Clear previous marks
        markRenderer.clear()
        
        // Render initial board state
        renderBoardState()
    }
    
    /// Renders the current board state
    private func renderBoardState() {
        guard let board = board else { return }
        let layout = gridLayout
        
        markRenderer.clear()
        
        for cellIndex in 0..<9 {
            if let player = board.player(at: cellIndex) {
                let position = layout.position(for: cellIndex)
                markRenderer.placeMark(
                    player.symbol,
                    at: cellIndex,
                    position: position,
                    cellSize: layout.cellSize
                )
            }
        }
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
    
    private func handleTap(at location: CGPoint) {
        // Check button taps
        if let node = atPoint(location) as? SKLabelNode {
            handleButtonTap(node)
            return
        }
        
        // Handle puzzle move
        if !isCompleted {
            attemptMove(at: location)
        }
    }
    
    private func handleButtonTap(_ node: SKLabelNode) {
        switch node.name {
        case "hintButton":
            showHint()
        case "resetButton":
            resetPuzzle()
        case "nextPuzzleButton":
            onNextPuzzle?()
        default:
            break
        }
    }
    
    // MARK: - Move Handling
    
    private func attemptMove(at location: CGPoint) {
        guard let puzzle = currentPuzzle,
              var board = board else { return }
        
        guard let cellIndex = gridLayout.cellIndex(at: location) else { return }
        guard !board.isCellOccupied(at: cellIndex) else { return }
        
        // Record the move
        currentAttempt?.recordMove(cellIndex)
        
        // Try to make the move
        guard board.makeMove(at: cellIndex) else { return }
        self.board = board
        
        // Place the mark visually
        let layout = gridLayout
        let position = layout.position(for: cellIndex)
        markRenderer.placeMark(
            board.lastPlayer.symbol,
            at: cellIndex,
            position: position,
            cellSize: layout.cellSize
        )
        
        SoundManager.shared.playTurn()
        
        // Check if move is correct
        if puzzle.isCorrectMove(cellIndex) {
            handleCorrectMove(puzzle, board: board)
        } else {
            handleIncorrectMove()
        }
    }
    
    private func handleCorrectMove(_ puzzle: GamePuzzle, board: GameBoard) {
        switch puzzle.type {
        case .oneMove:
            // One-move puzzles complete immediately
            completePuzzle(success: true)
            
        case .twoMove:
            // Check if sequence is complete
            let movesMade = currentAttempt?.moveSequence.count ?? 0
            if movesMade >= puzzle.solution.count {
                // Need to simulate opponent response and check final outcome
                if validateTwoMoveSolution(board: board, puzzle: puzzle) {
                    completePuzzle(success: true)
                } else {
                    completePuzzle(success: false)
                }
            } else {
                // Continue with sequence
                updateStatus()
            }
            
        case .defensive:
            // Defensive puzzles complete when block is made
            completePuzzle(success: true)
        }
    }
    
    private func handleIncorrectMove() {
        // Show failure feedback
        showFeedback("Try Again", color: Configuration.failureColor)
        SoundManager.shared.playDraw()
        
        // Slight delay before allowing retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.resetPuzzle()
        }
    }
    
    private func validateTwoMoveSolution(board: GameBoard, puzzle: GamePuzzle) -> Bool {
        // For two-move puzzles, we need to verify the sequence leads to victory
        // This is a simplified check - in production, use PuzzleStrategist
        return board.winner == puzzle.currentPlayer
    }
    
    // MARK: - Puzzle Completion
    
    private func completePuzzle(success: Bool) {
        isCompleted = true
        
        // Calculate time taken
        let timeElapsed = startTime.map { Date().timeIntervalSince($0) } ?? 0
        
        // Update attempt record
        currentAttempt?.complete(solved: success)
        
        // Show feedback
        if success {
            showFeedback("Perfect! ✨", color: Configuration.successColor)
            SoundManager.shared.playWin()
            
            // Show next button with SpriteKit animation (button starts at alpha 0)
            nextPuzzleButton.run(SKAction.fadeIn(withDuration: Configuration.animationDuration))
        } else {
            showFeedback("Not Quite!", color: Configuration.failureColor)
            SoundManager.shared.playDraw()
        }
        
        // Hide puzzle controls
        hintButton.alpha = 0
        resetButton.alpha = 0
        
        // Notify completion
        if let puzzle = currentPuzzle {
            onPuzzleCompleted?(puzzle, success, timeElapsed)
            
            // Save attempt data
            if let attempt = currentAttempt {
                PuzzleManager.shared.recordAttempt(attempt)
            }
        }
    }
    
    // MARK: - Hint System
    
    private func showHint() {
        hintsShown += 1
        
        // Fade in hint
        hintLabel.alpha = 0
        hintLabel.run(SKAction.fadeIn(withDuration: Configuration.animationDuration))
        
        // Optionally highlight the solution cell
        if let puzzle = currentPuzzle,
           let firstMove = puzzle.firstMove {
            highlightCell(firstMove)
        }
    }
    
    private func highlightCell(_ cellIndex: Int) {
        let layout = gridLayout
        let position = layout.position(for: cellIndex)
        let size = layout.cellSize
        
        // Create highlight shape
        let highlight = SKShapeNode(rectOf: CGSize(width: size * 0.9, height: size * 0.9), cornerRadius: 8)
        highlight.strokeColor = Configuration.hintColor
        highlight.lineWidth = 3
        highlight.fillColor = .clear
        highlight.position = position
        highlight.alpha = 0
        
        addChild(highlight)
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.5),
            SKAction.fadeAlpha(to: 0.3, duration: 0.5)
        ])
        let repeatPulse = SKAction.repeat(pulse, count: 3)
        let remove = SKAction.removeFromParent()
        
        highlight.run(SKAction.sequence([repeatPulse, remove]))
    }
    
    // MARK: - Puzzle Reset
    
    private func resetPuzzle() {
        guard let puzzle = currentPuzzle else { return }
        
        // Reset board to initial state
        board = puzzle.board
        
        // Clear and re-render
        markRenderer.clear()
        renderBoardState()
        
        // Reset attempt
        currentAttempt = PuzzleAttempt(
            puzzleId: puzzle.id,
            userDifficulty: PuzzleManager.shared.userProfile.currentDifficulty
        )
        
        // Reset UI
        feedbackLabel.alpha = 0
        hintLabel.alpha = 0
        
        updateStatus()
    }
    
    // MARK: - UI Updates
    
    private func updateStatus() {
        guard let puzzle = currentPuzzle else { return }
        
        let difficultyEmoji: String
        switch puzzle.difficulty {
        case .beginner: difficultyEmoji = "⭐️"
        case .intermediate: difficultyEmoji = "⭐️⭐️"
        case .advanced: difficultyEmoji = "⭐️⭐️⭐️"
        case .expert: difficultyEmoji = "⭐️⭐️⭐️⭐️"
        }
        
        statusLabel.text = "\(difficultyEmoji) \(puzzle.difficulty.rawValue.capitalized) • \(puzzle.type.displayName)"
    }
    
    private func showFeedback(_ text: String, color: SKColor) {
        feedbackLabel.text = text
        feedbackLabel.fontColor = color
        feedbackLabel.alpha = 0
        
        // Fade in and out
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let wait = SKAction.wait(forDuration: 1.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        
        feedbackLabel.run(SKAction.sequence([fadeIn, wait, fadeOut]))
    }
}
