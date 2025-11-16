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
    
    // MARK: - State
    
    /// The underlying game board model.
    private var board = GameBoard()
    
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
        gridRenderer.render(in: frame)
        updateStatusLabel()
        layoutStatusLabel()
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
        guard let cellIndex = gridLayout.cellIndex(at: location) else { return }
        guard board.makeMove(at: cellIndex) else { return }
        
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
        
        // Increment ad counter and potentially show an ad (only if SDK available)
        #if os(iOS) && canImport(GoogleMobileAds)
        if let viewController = view?.window?.rootViewController {
            AdManager.shared.incrementGameCounter(from: viewController)
        }
        #endif
    }
}
