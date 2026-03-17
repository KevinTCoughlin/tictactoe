//
//  AIOpponent.swift
//  tictactoe Shared
//
//  Created by AI Assistant
//

import Foundation
import FoundationModels

/// An AI opponent for tic-tac-toe that uses Foundation Models for strategic play.
///
/// This provides a more dynamic and varied playing style compared to traditional
/// minimax algorithms, with configurable difficulty levels that affect playing style.
@MainActor
@available(iOS 26.0, macOS 15.2, *)
public final class AIOpponent {
    
    // MARK: - Types
    
    /// Difficulty levels affect how the AI approaches the game
    public enum Difficulty {
        case easy       // Makes occasional mistakes, plays casually
        case medium     // Solid strategy with some variance
        case hard       // Near-optimal play with strategic thinking
        case adaptive   // Learns from player patterns (future enhancement)
    }
    
    @Generable(description: "AI's decision for next move in tic-tac-toe")
    struct MoveDecision {
        @Guide(description: "The cell index (0-8) where the AI will play")
        var moveIndex: Int
        
        @Guide(description: "One-sentence explanation of why this move was chosen")
        var reasoning: String
        
        @Guide(description: "Confidence level from 1-10")
        var confidence: Int
    }
    
    // MARK: - Properties
    
    private let model = SystemLanguageModel.default
    private var session: LanguageModelSession?
    private let difficulty: Difficulty
    private var moveHistory: [(board: GameBoard, move: Int)] = []
    
    // MARK: - Initialization
    
    public init(difficulty: Difficulty = .medium) {
        self.difficulty = difficulty
    }
    
    // MARK: - Public Methods
    
    /// Checks if the AI opponent is available on this device
    public var isAvailable: Bool {
        switch model.availability {
        case .available:
            return true
        default:
            return false
        }
    }
    
    /// Calculates the AI's next move
    ///
    /// - Parameter board: The current game state
    /// - Returns: The cell index (0-8) where the AI will play
    /// - Throws: If the model is unavailable or move generation fails
    public func calculateMove(for board: GameBoard) async throws -> Int {
        // Fallback to simple AI if Foundation Models unavailable
        guard isAvailable else {
            return calculateFallbackMove(for: board)
        }
        
        // Initialize session if needed
        if session == nil {
            session = createSession()
        }
        
        guard let session = session else {
            return calculateFallbackMove(for: board)
        }
        
        let prompt = buildPrompt(for: board)
        
        do {
            let response = try await session.respond(
                to: prompt,
                generating: MoveDecision.self
            )
            
            let move = response.content.moveIndex
            
            // Validate the move
            guard (0..<9).contains(move) && board.player(at: move) == nil else {
                print("AI suggested invalid move \(move), falling back")
                return calculateFallbackMove(for: board)
            }
            
            // Store in history for learning (future enhancement)
            moveHistory.append((board, move))
            
            return move
            
        } catch {
            print("AI move generation failed: \(error), falling back")
            return calculateFallbackMove(for: board)
        }
    }
    
    /// Gets an explanation for the AI's most recent move
    public func explainLastMove() -> String? {
        guard let lastEntry = moveHistory.last else {
            return nil
        }
        
        return "AI played position \(lastEntry.move)"
    }
    
    /// Resets the AI's learning history
    public func reset() {
        session = nil
        moveHistory.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func createSession() -> LanguageModelSession {
        let instructions = createInstructions()
        return LanguageModelSession(instructions: instructions)
    }
    
    private func createInstructions() -> String {
        let baseInstructions = """
        You are an AI playing tic-tac-toe.
        Analyze the board and choose your next move strategically.
        Your response must include a valid move index (0-8) for an empty cell.
        
        Key strategies:
        - Win if possible
        - Block opponent wins
        - Control the center (position 4)
        - Take corners when advantageous
        - Create fork opportunities
        """
        
        switch difficulty {
        case .easy:
            return baseInstructions + """
            
            Play casually and make occasional suboptimal moves.
            Sometimes miss blocking opportunities.
            Focus on making the game fun for beginners.
            """
            
        case .medium:
            return baseInstructions + """
            
            Play with solid strategy but with some variation.
            Prioritize winning and blocking, but explore different tactics.
            """
            
        case .hard:
            return baseInstructions + """
            
            Play optimally using minimax principles.
            Always block wins and take winning moves.
            Create forks when possible.
            Play aggressively to win.
            """
            
        case .adaptive:
            return baseInstructions + """
            
            Analyze the opponent's playing patterns and adapt your strategy.
            Learn from their mistakes and strengths.
            Adjust difficulty dynamically to keep games competitive.
            """
        }
    }
    
    private func buildPrompt(for board: GameBoard) -> String {
        let boardDescription = describeBoardState(board)
        let availableMoves = getAvailableMoves(for: board)
        let aiSymbol = board.currentPlayer.symbol
        let opponentSymbol = board.currentPlayer.opponent.symbol
        
        var prompt = """
        Current board state:
        \(boardDescription)
        
        You are playing as \(aiSymbol).
        Your opponent is \(opponentSymbol).
        Available moves: \(availableMoves.map(String.init).joined(separator: ", "))
        
        Choose your next move strategically.
        """
        
        // Add move history context for adaptive mode
        if difficulty == .adaptive && !moveHistory.isEmpty {
            prompt += """
            
            Recent game history shows these patterns:
            \(summarizeGameHistory())
            """
        }
        
        return prompt
    }
    
    private func describeBoardState(_ board: GameBoard) -> String {
        var result = ""
        for row in 0..<3 {
            for col in 0..<3 {
                let index = row * 3 + col
                if let player = board.player(at: index) {
                    result += player.symbol
                } else {
                    result += String(index)
                }
                if col < 2 { result += " | " }
            }
            if row < 2 { result += "\n---------\n" }
        }
        return result
    }
    
    private func getAvailableMoves(for board: GameBoard) -> [Int] {
        (0..<9).filter { board.player(at: $0) == nil }
    }
    
    private func summarizeGameHistory() -> String {
        let recentMoves = moveHistory.suffix(5)
        return recentMoves.map { "Move \($0.move)" }.joined(separator: ", ")
    }
    
    // MARK: - Fallback Strategy
    
    /// Simple rule-based AI as fallback when Foundation Models unavailable
    private func calculateFallbackMove(for board: GameBoard) -> Int {
        let availableMoves = getAvailableMoves(for: board)
        guard !availableMoves.isEmpty else {
            return 0 // Should never happen in valid game
        }
        
        // 1. Check for winning move
        if let winningMove = findWinningMove(for: board, player: board.currentPlayer) {
            return winningMove
        }
        
        // 2. Block opponent's winning move
        if let blockingMove = findWinningMove(for: board, player: board.currentPlayer.opponent) {
            return blockingMove
        }
        
        // 3. Take center if available
        if availableMoves.contains(4) {
            return 4
        }
        
        // 4. Take a corner
        let corners = [0, 2, 6, 8]
        let availableCorners = corners.filter { availableMoves.contains($0) }
        if let corner = availableCorners.randomElement() {
            return corner
        }
        
        // 5. Take any available move
        return availableMoves.randomElement()!
    }
    
    private func findWinningMove(for board: GameBoard, player: Player) -> Int? {
        let availableMoves = getAvailableMoves(for: board)
        
        for move in availableMoves {
            // Check if this move would create a win by examining the board state
            if wouldWin(board: board, player: player, move: move) {
                return move
            }
        }
        
        return nil
    }
    
    /// Checks if a hypothetical move would result in a win for the specified player
    private func wouldWin(board: GameBoard, player: Player, move: Int) -> Bool {
        // Get the player's current mask
        let currentMask = (player == .x) ? board.xMask : board.oMask
        
        // Calculate what the mask would be with this move
        let cellBit = 1 << (8 - move)
        let hypotheticalMask = currentMask | cellBit
        
        // Check if the hypothetical mask matches any winning pattern
        for pattern in GameBoard.winningPatterns {
            if (hypotheticalMask & pattern.mask) == pattern.mask {
                return true
            }
        }
        
        return false
    }
}

// MARK: - SwiftUI Integration Example

#if canImport(SwiftUI)
import SwiftUI

/// Example view showing AI opponent in action
@available(iOS 26.0, macOS 15.2, *)
public struct AIGameView: View {
    @State private var board = GameBoard()
    @State private var aiOpponent = AIOpponent(difficulty: .medium)
    @State private var isAIThinking = false
    @State private var message = "Your turn!"
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.title2)
            
            // Game board (simplified for example)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(0..<9, id: \.self) { index in
                    Button {
                        handlePlayerMove(at: index)
                    } label: {
                        Text(board.player(at: index)?.symbol ?? "")
                            .font(.largeTitle)
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .disabled(board.player(at: index) != nil || isAIThinking || board.isGameOver)
                }
            }
            
            if board.isGameOver {
                Button("New Game") {
                    board.reset()
                    aiOpponent.reset()
                    message = "Your turn!"
                }
                .buttonStyle(.borderedProminent)
            }
            
            if !aiOpponent.isAvailable {
                Text("AI requires Apple Intelligence")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .overlay {
            if isAIThinking {
                ZStack {
                    Color.black.opacity(0.3)
                    ProgressView("AI is thinking...")
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func handlePlayerMove(at index: Int) {
        guard board.makeMove(at: index) else { return }
        
        if board.isGameOver {
            updateMessage()
            return
        }
        
        // AI's turn
        Task {
            await makeAIMove()
        }
    }
    
    private func makeAIMove() async {
        isAIThinking = true
        message = "AI is thinking..."
        
        do {
            let move = try await aiOpponent.calculateMove(for: board)
            
            // Small delay for better UX
            try await Task.sleep(for: .seconds(0.5))
            
            board.makeMove(at: move)
            updateMessage()
            
        } catch {
            message = "AI error: \(error.localizedDescription)"
        }
        
        isAIThinking = false
    }
    
    private func updateMessage() {
        if let winner = board.winner {
            message = winner == .x ? "You won! 🎉" : "AI won! 🤖"
        } else if board.isDraw {
            message = "It's a draw!"
        } else {
            message = "Your turn!"
        }
    }
}
#endif
