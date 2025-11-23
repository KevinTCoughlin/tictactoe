//
//  AIGameCoach.swift
//  tictactoe Shared
//
//  Created by AI Assistant
//

import Foundation
import FoundationModels

/// An AI-powered coach that provides strategic advice for tic-tac-toe gameplay.
///
/// Uses Apple's on-device Foundation Models to analyze game state and provide
/// contextual hints, strategy tips, and move explanations.
@MainActor
@Observable
public final class AIGameCoach {
    
    // MARK: - Types
    
    /// Represents different types of coaching advice
    public enum CoachingStyle {
        case beginner      // Simple, encouraging tips
        case intermediate  // Strategic analysis
        case advanced      // Deep tactical insights
    }
    
    @Generable(description: "Strategic advice for a tic-tac-toe move")
    public struct MoveAdvice {
        @Guide(description: "A concise explanation of why this move is good (one sentence)")
        public var reasoning: String
        
        @Guide(description: "The recommended cell index to play (0-8)")
        public var recommendedMove: Int
        
        @Guide(description: "A brief encouraging message for the player")
        public var encouragement: String
    }
    
    // MARK: - Properties
    
    private let model = SystemLanguageModel.default
    private var session: LanguageModelSession?
    private let style: CoachingStyle
    
    // MARK: - Initialization
    
    public init(style: CoachingStyle = .intermediate) {
        self.style = style
    }
    
    // MARK: - Public Methods
    
    /// Checks if the AI coach is available on this device
    public var isAvailable: Bool {
        switch model.availability {
        case .available:
            return true
        default:
            return false
        }
    }
    
    /// Provides coaching advice for the current game state
    ///
    /// - Parameters:
    ///   - board: The current game board
    /// - Returns: Strategic advice including recommended move and reasoning
    public func provideAdvice(for board: GameBoard) async throws -> MoveAdvice {
        // Initialize session if needed
        if session == nil {
            session = createSession()
        }
        
        guard let session = session else {
            throw CoachError.sessionNotAvailable
        }
        
        // Build the prompt based on current board state
        let prompt = buildPrompt(for: board)
        
        // Get structured advice from the model
        let response = try await session.respond(
            to: prompt,
            generating: MoveAdvice.self
        )
        
        return response.content
    }
    
    /// Explains why a move was good or bad
    ///
    /// - Parameters:
    ///   - moveIndex: The cell index of the move to explain
    ///   - board: The board state before the move
    /// - Returns: An explanation of the move's strategic value
    public func explainMove(_ moveIndex: Int, on board: GameBoard) async throws -> String {
        if session == nil {
            session = createSession()
        }
        
        guard let session = session else {
            throw CoachError.sessionNotAvailable
        }
        
        let prompt = """
        A player just made a move at position \(moveIndex) on this tic-tac-toe board:
        \(describeBoardState(board))
        
        Explain in one friendly sentence whether this was a good move and why.
        """
        
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    /// Resets the coaching session (clears conversation history)
    public func resetSession() {
        session = nil
    }
    
    // MARK: - Private Methods
    
    private func createSession() -> LanguageModelSession {
        let instructions = createInstructions()
        return LanguageModelSession(instructions: instructions)
    }
    
    private func createInstructions() -> String {
        let baseInstructions = """
        You are a friendly and encouraging tic-tac-toe coach.
        Your goal is to help players improve their game strategy.
        Always be positive and supportive.
        Keep explanations brief and clear.
        """
        
        switch style {
        case .beginner:
            return baseInstructions + """
            
            Focus on basic concepts like:
            - Blocking opponent wins
            - Taking the center
            - Creating two-way win opportunities
            Use simple language and lots of encouragement.
            """
            
        case .intermediate:
            return baseInstructions + """
            
            Provide strategic insights about:
            - Fork opportunities
            - Defensive positioning
            - Corner strategies
            Balance tactical advice with encouragement.
            """
            
        case .advanced:
            return baseInstructions + """
            
            Offer advanced analysis including:
            - Optimal opening theory
            - Minimax strategy implications
            - Endgame patterns
            Assume familiarity with game theory concepts.
            """
        }
    }
    
    private func buildPrompt(for board: GameBoard) -> String {
        let boardDescription = describeBoardState(board)
        let availableMoves = getAvailableMoves(for: board)
        
        return """
        Current board state:
        \(boardDescription)
        
        Available moves: \(availableMoves.map(String.init).joined(separator: ", "))
        Current player: \(board.currentPlayer == .x ? "X" : "O")
        
        Provide strategic advice for the current player's next move.
        Consider winning moves, blocking opponent wins, and strategic positioning.
        """
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
    
    // MARK: - Error Types
    
    public enum CoachError: LocalizedError {
        case sessionNotAvailable
        case modelUnavailable
        
        public var errorDescription: String? {
            switch self {
            case .sessionNotAvailable:
                return "AI coaching session could not be initialized."
            case .modelUnavailable:
                return "AI model is not available on this device."
            }
        }
    }
}

// MARK: - SwiftUI Integration Example

#if canImport(SwiftUI)
import SwiftUI

/// A SwiftUI view that displays AI coaching advice
public struct CoachingView: View {
    @State private var coach = AIGameCoach()
    @State private var advice: AIGameCoach.MoveAdvice?
    @State private var isLoading = false
    @State private var error: Error?
    
    let board: GameBoard
    
    public init(board: GameBoard) {
        self.board = board
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            if coach.isAvailable {
                if isLoading {
                    ProgressView("Getting advice...")
                } else if let advice = advice {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 Coaching Tip")
                            .font(.headline)
                        
                        Text(advice.reasoning)
                            .font(.body)
                        
                        Text("Try position \(advice.recommendedMove)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        
                        Text(advice.encouragement)
                            .font(.caption)
                            .italic()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                } else if let error = error {
                    VStack {
                        Text("⚠️ Error")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                    }
                    .foregroundStyle(.red)
                }
                
                Button("Get Advice") {
                    Task {
                        await fetchAdvice()
                    }
                }
                .disabled(isLoading || board.isGameOver)
            } else {
                Text("AI coaching requires Apple Intelligence")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    private func fetchAdvice() async {
        isLoading = true
        error = nil
        
        do {
            advice = try await coach.provideAdvice(for: board)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
#endif
