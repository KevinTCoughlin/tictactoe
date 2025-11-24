//
//  AICommentaryManager.swift
//  tictactoe Shared
//
//  Created by AI Assistant on 11/23/25.
//

import Foundation
import SpriteKit
import OSLog

/// Manages AI commentary integration with the game scene.
///
/// This manager coordinates commentary generation, display, and streaming
/// to provide an entertaining play-by-play experience.
@MainActor
final class AICommentaryManager {
    
    // MARK: - Properties
    
    /// The AI commentator instance
    private let commentator: AICommentator
    
    /// Whether commentary is currently enabled
    private(set) var isEnabled: Bool = false
    
    /// Logger for debugging
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "tictactoe", category: "AICommentaryManager")
    
    /// Callback when new commentary is available
    var onCommentaryUpdate: ((String) -> Void)?
    
    /// Whether commentary is currently being generated
    private(set) var isGenerating = false
    
    // MARK: - Initialization
    
    init(style: AICommentator.CommentaryStyle = .enthusiastic) {
        self.commentator = AICommentator(style: style)
        logger.info("AICommentaryManager initialized with style: \(String(describing: style))")
    }
    
    // MARK: - Public Methods
    
    /// Checks if commentary is available on this device
    var isAvailable: Bool {
        commentator.isAvailable
    }
    
    /// Enables or disables commentary
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        logger.info("Commentary \(enabled ? "enabled" : "disabled")")
    }
    
    /// Generates commentary for a move
    func commentOnMove(
        _ moveIndex: Int,
        board: GameBoard,
        player: Player
    ) {
        guard isEnabled else { return }
        guard !isGenerating else {
            logger.warning("Commentary already being generated, skipping")
            return
        }
        
        isGenerating = true
        
        Task {
            do {
                let commentary = try await commentator.commentOnMove(
                    moveIndex,
                    board: board,
                    player: player
                )
                
                // Create combined text
                let fullCommentary = """
                🎙️ \(commentary.playByPlay)
                \(commentary.analysis)
                """
                
                await MainActor.run {
                    isGenerating = false
                    onCommentaryUpdate?(fullCommentary)
                }
                
            } catch {
                logger.error("Commentary generation failed: \(error.localizedDescription)")
                await MainActor.run {
                    isGenerating = false
                }
            }
        }
    }
    
    /// Generates opening commentary for game start
    func generateOpeningCommentary() {
        guard isEnabled else { return }
        
        Task {
            do {
                let commentary = try await commentator.openingCommentary()
                await MainActor.run {
                    onCommentaryUpdate?("🎙️ " + commentary)
                }
            } catch {
                logger.error("Opening commentary failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Generates closing commentary for game end
    func generateClosingCommentary(for board: GameBoard) {
        guard isEnabled else { return }
        
        Task {
            do {
                let commentary = try await commentator.closingCommentary(for: board)
                await MainActor.run {
                    onCommentaryUpdate?("🎙️ " + commentary)
                }
            } catch {
                logger.error("Closing commentary failed: \(error.localizedDescription)")
            }
        }
    }
    
    // (setStyle(_:) removed: changing commentary style at runtime is not supported)
    
    /// Resets commentary state
    func reset() {
        commentator.reset()
        isGenerating = false
        logger.debug("Commentary manager reset")
    }
}

// MARK: - Commentary Display

/// A SpriteKit node that displays commentary with nice styling
final class CommentaryDisplayNode: SKNode {
    
    // MARK: - Configuration
    
    private struct Config {
        static let backgroundColor = SKColor.systemBlue.withAlphaComponent(0.9)
        static let textColor = SKColor.white
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let maxWidth: CGFloat = 300
        static let fontSize: CGFloat = 14
        static let fadeInDuration: TimeInterval = 0.3
        static let fadeOutDuration: TimeInterval = 0.2
        static let autoHideDelay: TimeInterval = 5.0
    }
    
    // MARK: - Properties
    
    private let backgroundShape = SKShapeNode()
    private let textLabel = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Regular")
    private let iconLabel = SKLabelNode(text: "🎙️")
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupNodes() {
        // Configure text label
        textLabel.fontSize = Config.fontSize
        textLabel.fontColor = Config.textColor
        textLabel.horizontalAlignmentMode = .left
        textLabel.verticalAlignmentMode = .center
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = Config.maxWidth - (Config.padding * 2)
        
        // Configure icon
        iconLabel.fontSize = 20
        iconLabel.horizontalAlignmentMode = .left
        iconLabel.verticalAlignmentMode = .center
        
        // Add to hierarchy (background added dynamically)
        addChild(backgroundShape)
        addChild(iconLabel)
        addChild(textLabel)
        
        // Start hidden
        alpha = 0
    }
    
    // MARK: - Public Methods
    
    /// Shows commentary with animation
    func show(commentary: String, at position: CGPoint) {
        // Update text
        textLabel.text = commentary
        
        // Calculate size
        let textSize = textLabel.frame.size
        let width = min(textSize.width + (Config.padding * 3) + 30, Config.maxWidth)
        let height = textSize.height + (Config.padding * 2)
        
        // Update background
        let rect = CGRect(x: 0, y: -height/2, width: width, height: height)
        let path = CGPath(roundedRect: rect, cornerWidth: Config.cornerRadius, cornerHeight: Config.cornerRadius, transform: nil)
        backgroundShape.path = path
        backgroundShape.fillColor = Config.backgroundColor
        backgroundShape.strokeColor = .clear
        
        // Position elements
        iconLabel.position = CGPoint(x: Config.padding, y: 0)
        textLabel.position = CGPoint(x: Config.padding * 2 + 25, y: 0)
        
        // Position node
        self.position = position
        
        // Animate in
        removeAllActions()
        let fadeIn = SKAction.fadeIn(withDuration: Config.fadeInDuration)
        let wait = SKAction.wait(forDuration: Config.autoHideDelay)
        let fadeOut = SKAction.fadeOut(withDuration: Config.fadeOutDuration)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut])
        
        run(sequence)
    }
    
    /// Hides commentary immediately
    func hide() {
        removeAllActions()
        run(SKAction.fadeOut(withDuration: Config.fadeOutDuration))
    }
}
