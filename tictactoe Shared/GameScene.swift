//
//  GameScene.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/2/25.
//  Refactored by Kevin T. Coughlin on 11/16/25.
//

import SpriteKit

/// The main game scene for tic-tac-toe, handling user interaction and coordinating rendering.
///
/// This scene acts as the main controller, delegating rendering responsibilities to
/// specialized components (GridRenderer, MarkRenderer, WinningLineAnimator) while
/// managing the game state and user input.
final class GameScene: SKScene {
    
    // MARK: - Configuration
    
    /// Centralized configuration for the game scene.
    private struct Configuration {
        static let gridScaleFactor: CGFloat = 0.85
        static let gridDimension = 3
        static let statusLabelSpacing: CGFloat = 60
        static let statusFontSize: CGFloat = 24
        static let markFontScale: CGFloat = 0.65
        static let gridLineWidth: CGFloat = 2
        static let winLineWidth: CGFloat = 8
        static let winLineGlowWidth: CGFloat = 16
        static let gridFadeAlpha: CGFloat = 0.25
        static let markAnimationDuration: TimeInterval = 0.15
        static let fadeAnimationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Components
    
    /// Handles rendering of the grid lines.
    private lazy var gridRenderer = GridRenderer(
        scene: self,
        scaleFactor: Configuration.gridScaleFactor,
        dimension: Configuration.gridDimension,
        lineWidth: Configuration.gridLineWidth
    )
    
    /// Handles rendering of player marks (X and O).
    private lazy var markRenderer = MarkRenderer(
        scene: self,
        fontScale: Configuration.markFontScale,
        animationDuration: Configuration.markAnimationDuration
    )
    
    /// Handles animation of the winning line.
    private lazy var winningLineAnimator = WinningLineAnimator(
        scene: self,
        lineWidth: Configuration.winLineWidth,
        glowWidth: Configuration.winLineGlowWidth
    )
    
    /// Label displaying current game status (turn, winner, or draw).
    private lazy var statusLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Semibold")
        label.fontSize = Configuration.statusFontSize
        label.fontColor = .label
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .top
        return label
    }()
    
    /// Button to toggle AI mode
    private lazy var aiModeButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Semibold")
        label.fontSize = 16
        label.fontColor = .systemBlue
        label.horizontalAlignmentMode = .right
        label.verticalAlignmentMode = .top
        label.text = "AI: OFF"
        label.name = "aiModeButton"
        return label
    }()
    
    /// Button to toggle commentary
    private lazy var commentaryButton: SKLabelNode = {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Semibold")
        label.fontSize = 16
        label.fontColor = .systemBlue
        label.horizontalAlignmentMode = .right
        label.verticalAlignmentMode = .top
        label.text = "🎙️: OFF"
        label.name = "commentaryButton"
        return label
    }()
    
    // MARK: - State
    
    /// The underlying game board model.
    private var board = GameBoard()
    
    /// The AI game manager for handling AI opponent
    @available(iOS 26.0, macOS 15.2, *)
    private lazy var aiManager: AIGameManager = {
        let manager = AIGameManager(difficulty: .medium)
        manager.onAIMove = { [weak self] cellIndex in
            self?.handleAIMove(at: cellIndex)
        }
        return manager
    }()
    
    /// The AI commentary manager for play-by-play commentary
    @available(iOS 26.0, macOS 15.2, *)
    private lazy var commentaryManager: AICommentaryManager = {
        let manager = AICommentaryManager(style: .enthusiastic)
        manager.onCommentaryUpdate = { [weak self] commentary in
            self?.showCommentary(commentary)
        }
        return manager
    }()
    
    /// Node for displaying commentary
    private lazy var commentaryDisplay = CommentaryDisplayNode()
    
    /// The current grid layout based on scene dimensions.
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
    
    /// Performs initial setup of the scene.
    private func setupScene() {
        configureBackgroundColor()
        addChild(statusLabel)
        if #available(iOS 26.0, macOS 15.2, *) {
            addChild(aiModeButton)
            addChild(commentaryButton)
            addChild(commentaryDisplay)
        }
        gridRenderer.render(in: frame)
        updateStatusLabel()
        layoutStatusLabel()
        if #available(iOS 26.0, macOS 15.2, *) {
            layoutAIModeButton()
            layoutCommentaryButton()
            
            // Show opening commentary if enabled
            if commentaryManager.isEnabled {
                commentaryManager.generateOpeningCommentary()
            }
        }
    }
    
    /// Configures the background color based on the platform.
    private func configureBackgroundColor() {
        #if os(iOS) || os(tvOS)
        backgroundColor = .systemBackground
        #else
        backgroundColor = .windowBackgroundColor
        #endif
    }
    
    /// Re-layouts all scene elements after a size change.
    private func relayoutScene() {
        gridRenderer.render(in: frame)
        markRenderer.relayout(using: gridLayout)
        layoutStatusLabel()
        if #available(iOS 26.0, macOS 15.2, *) {
            layoutAIModeButton()
            layoutCommentaryButton()
        }
    }
    
    // MARK: - Status Label
    
    /// Positions the status label above the grid.
    private func layoutStatusLabel() {
        let layout = gridLayout
        statusLabel.position = CGPoint(
            x: frame.midX,
            y: layout.gridOrigin.y + layout.gridSize + Configuration.statusLabelSpacing
        )
    }
    
    /// Updates the status label text based on current game state.
    private func updateStatusLabel() {
        statusLabel.text = statusText
    }
    
    /// Positions the AI mode button in the top-right corner
    @available(iOS 26.0, macOS 15.2, *)
    private func layoutAIModeButton() {
        let padding: CGFloat = 20
        aiModeButton.position = CGPoint(
            x: frame.maxX - padding,
            y: frame.maxY - padding
        )
    }
    
    /// Positions the commentary button below the AI button
    @available(iOS 26.0, macOS 15.2, *)
    private func layoutCommentaryButton() {
        let padding: CGFloat = 20
        let buttonSpacing: CGFloat = 30
        commentaryButton.position = CGPoint(
            x: frame.maxX - padding,
            y: frame.maxY - padding - buttonSpacing
        )
    }
    
    /// Updates the AI mode button appearance
    @available(iOS 26.0, macOS 15.2, *)
    private func updateAIModeButton() {
        let isAIMode = aiManager.gameMode == .playerVsAI
        aiModeButton.text = isAIMode ? "AI: ON" : "AI: OFF"
        aiModeButton.fontColor = isAIMode ? .systemGreen : .systemBlue
    }
    
    /// Updates the commentary button appearance
    @available(iOS 26.0, macOS 15.2, *)
    private func updateCommentaryButton() {
        let isEnabled = commentaryManager.isEnabled
        commentaryButton.text = isEnabled ? "🎙️: ON" : "🎙️: OFF"
        commentaryButton.fontColor = isEnabled ? .systemOrange : .systemBlue
    }
    
    /// The text to display in the status label based on game state.
    private var statusText: String {
        if let winner = board.winner {
            return "Winner: \(winner.symbol) — tap to reset"
        } else if board.isDraw {
            return "Draw — tap to reset"
        } else {
            // Include AI status if in AI mode
            if #available(iOS 26.0, macOS 15.2, *) {
                let aiStatus = aiManager.statusText(for: board)
                if !aiStatus.isEmpty {
                    return aiStatus
                }
            }
            return "Turn: \(board.currentPlayer.symbol)"
        }
    }
    
    // MARK: - Game Actions
    
    /// Places a mark at the specified cell index with animation.
    private func placeMark(at cellIndex: Int) {
        let layout = gridLayout
        let position = layout.position(for: cellIndex)
        
        markRenderer.placeMark(
            board.lastPlayer.symbol,
            at: cellIndex,
            position: position,
            cellSize: layout.cellSize
        )
        
        SoundManager.shared.playTurn()
        
        // Generate commentary for this move
        if #available(iOS 26.0, macOS 15.2, *) {
            commentaryManager.commentOnMove(
                cellIndex,
                board: board,
                player: board.lastPlayer
            )
        }
        
        if board.isGameOver {
            handleGameOver()
        }
    }
    
    /// Handles visual updates when the game ends.
    private func handleGameOver() {
        if let line = board.winningLine {
            let layout = gridLayout
            let startPosition = layout.position(for: line.startCell)
            let endPosition = layout.position(for: line.endCell)
            
            winningLineAnimator.showWinningLine(from: startPosition, to: endPosition)
            gridRenderer.fade(to: Configuration.gridFadeAlpha, duration: Configuration.fadeAnimationDuration)
            SoundManager.shared.playWin()
        } else if board.isDraw {
            SoundManager.shared.playDraw()
        }
        
        // Generate closing commentary
        if #available(iOS 26.0, macOS 15.2, *) {
            commentaryManager.generateClosingCommentary(for: board)
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
    
    /// Handles tap/click input at the specified location.
    private func handleTap(at location: CGPoint) {
        if #available(iOS 26.0, macOS 15.2, *) {
            // Check if AI mode button was tapped
            if let tappedNode = atPoint(location) as? SKLabelNode,
               tappedNode.name == "aiModeButton" {
                toggleAIMode()
                return
            }
            
            // Check if commentary button was tapped
            if let tappedNode = atPoint(location) as? SKLabelNode,
               tappedNode.name == "commentaryButton" {
                toggleCommentary()
                return
            }
        }
        
        if board.isGameOver {
            resetGame()
        } else {
            attemptMove(at: location)
        }
    }
    
    /// Toggles between Player vs Player and Player vs AI mode
    @available(iOS 26.0, macOS 15.2, *)
    private func toggleAIMode() {
        let newMode: AIGameManager.GameMode = (aiManager.gameMode == .playerVsPlayer) ? .playerVsAI : .playerVsPlayer
        aiManager.setGameMode(newMode)
        updateAIModeButton()
        
        // Reset the game when toggling modes
        resetGame()
    }
    
    /// Toggles commentary on/off
    @available(iOS 26.0, macOS 15.2, *)
    private func toggleCommentary() {
        let newState = !commentaryManager.isEnabled
        commentaryManager.setEnabled(newState)
        updateCommentaryButton()
        
        // Show welcome message when enabling
        if newState {
            showCommentary("🎙️ Commentary enabled! Let's make this exciting!")
        } else {
            commentaryDisplay.hide()
        }
    }
    
    /// Shows commentary on screen
    @available(iOS 26.0, macOS 15.2, *)
    private func showCommentary(_ text: String) {
        let layout = gridLayout
        let yPosition = layout.gridOrigin.y - 60 // Below the grid
        let position = CGPoint(x: frame.midX, y: yPosition)
        
        commentaryDisplay.show(commentary: text, at: position)
    }
    
    /// Attempts to make a move at the tapped location.
    private func attemptMove(at location: CGPoint) {
        guard let cellIndex = gridLayout.cellIndex(at: location) else { return }
        guard board.makeMove(at: cellIndex) else { return }
        
        placeMark(at: cellIndex)
        updateStatusLabel()
        
        // Check if AI should move next
        if #available(iOS 26.0, macOS 15.2, *) {
            checkForAITurn()
        }
    }
    
    /// Checks if it's AI's turn and requests a move
    @available(iOS 26.0, macOS 15.2, *)
    private func checkForAITurn() {
        guard !board.isGameOver else { return }
        
        if aiManager.isAITurn(for: board) {
            aiManager.requestAIMove(for: board)
        }
    }
    
    /// Handles when the AI makes a move
    @available(iOS 26.0, macOS 15.2, *)
    private func handleAIMove(at cellIndex: Int) {
        guard board.makeMove(at: cellIndex) else {
            // AI made an invalid move - this shouldn't happen
            return
        }
        
        placeMark(at: cellIndex)
        updateStatusLabel()
    }
    
    // MARK: - Game Reset
    
    /// Resets the game to its initial state.
    private func resetGame() {
        board.reset()
        markRenderer.clear()
        winningLineAnimator.removeWinningLine()
        gridRenderer.restore()
        updateStatusLabel()
        SoundManager.shared.playReset()
        
        if #available(iOS 26.0, macOS 15.2, *) {
            // Reset AI manager
            aiManager.reset()
            
            // Reset commentary
            commentaryManager.reset()
            commentaryDisplay.hide()
            
            // Show opening commentary if enabled
            if commentaryManager.isEnabled {
                commentaryManager.generateOpeningCommentary()
            }
            
            // If AI plays as X (goes first), trigger AI move
            checkForAITurn()
        }
        
        // Increment ad counter and potentially show an ad (only if SDK available)
        #if os(iOS) && canImport(GoogleMobileAds)
        if let viewController = view?.window?.rootViewController {
            AdManager.shared.incrementGameCounter(from: viewController)
        }
        #endif
    }
}
