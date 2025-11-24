//
//  AIGameManager.swift
//  tictactoe Shared
//
//  Created by AI Assistant on 11/23/25.
//

import Foundation
import OSLog

/// Manages AI opponent gameplay and coordinates with GameScene.
///
/// This manager handles AI move calculations, game mode switching (PvP vs AI),
/// and provides a clean interface for the GameScene to interact with AI features.
@MainActor
@available(iOS 26.0, macOS 15.2, *)
final class AIGameManager {
    
    // MARK: - Types
    
    /// Available game modes
    enum GameMode {
        case playerVsPlayer      // Two human players
        case playerVsAI          // Human vs AI opponent
        case aiVsAI              // Watch two AIs play (future)
    }
    
    /// Represents which player the human controls when playing against AI
    enum HumanPlayer {
        case x    // Human plays as X (goes first)
        case o    // Human plays as O (goes second)
    }
    
    // MARK: - Properties
    
    /// Current game mode
    private(set) var gameMode: GameMode = .playerVsPlayer
    
    /// Which player the human controls in AI mode
    private(set) var humanPlayer: HumanPlayer = .x
    
    /// The AI opponent instance
    private var aiOpponent: AIOpponent
    
    /// Logger for debugging
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "tictactoe", category: "AIGameManager")
    
    /// Callback when AI wants to make a move
    var onAIMove: ((Int) -> Void)?
    
    /// Whether AI is currently thinking
    private(set) var isAIThinking = false
    
    // MARK: - Initialization
    
    init(difficulty: AIOpponent.Difficulty = .medium) {
        self.aiOpponent = AIOpponent(difficulty: difficulty)
        logger.info("AIGameManager initialized with difficulty: \(String(describing: difficulty))")
    }
    
    // MARK: - Public Methods
    
    /// Checks if AI features are available on this device
    var isAIAvailable: Bool {
        aiOpponent.isAvailable
    }
    
    /// Sets the game mode
    func setGameMode(_ mode: GameMode) {
        gameMode = mode
        logger.info("Game mode changed to: \(String(describing: mode))")
    }
    
    /// Sets which player the human controls
    func setHumanPlayer(_ player: HumanPlayer) {
        humanPlayer = player
        logger.info("Human player set to: \(String(describing: player))")
    }
    
    /// Changes AI difficulty by creating a new opponent instance
    func setDifficulty(_ difficulty: AIOpponent.Difficulty) {
        aiOpponent = AIOpponent(difficulty: difficulty)
        logger.info("AI difficulty changed to: \(String(describing: difficulty))")
    }
    
    /// Checks if it's currently the AI's turn
    func isAITurn(for board: GameBoard) -> Bool {
        guard gameMode == .playerVsAI else { return false }
        
        // Determine if current player matches AI's side
        let aiPlayerSymbol: Player = (humanPlayer == .x) ? .o : .x
        return board.currentPlayer == aiPlayerSymbol
    }
    
    /// Requests the AI to make its move
    func requestAIMove(for board: GameBoard) {
        guard !isAIThinking else {
            logger.warning("AI is already thinking, ignoring duplicate request")
            return
        }
        
        guard isAITurn(for: board) else {
            logger.warning("Not AI's turn, ignoring move request")
            return
        }
        
        isAIThinking = true
        logger.debug("AI thinking started...")
        
        Task {
            do {
                // Add slight delay for better UX (feels more natural)
                try await Task.sleep(for: .milliseconds(300))
                
                let move = try await aiOpponent.calculateMove(for: board)
                
                logger.info("AI decided to play at position \(move)")
                
                // Notify via callback
                await MainActor.run {
                    isAIThinking = false
                    onAIMove?(move)
                }
                
            } catch {
                logger.error("AI move calculation failed: \(error.localizedDescription)")
                
                await MainActor.run {
                    isAIThinking = false
                }
            }
        }
    }
    
    /// Resets AI state for a new game
    func reset() {
        aiOpponent.reset()
        isAIThinking = false
        logger.debug("AI manager reset")
    }
    
    /// Gets status text about the AI
    func statusText(for board: GameBoard) -> String {
        guard gameMode == .playerVsAI else {
            return ""
        }
        
        if isAIThinking {
            return "AI is thinking..."
        }
        
        if isAITurn(for: board) {
            return "AI's turn"
        }
        
        return "Your turn"
    }
}
