//
//  AICommentator.swift
//  tictactoe Shared
//
//  Created by AI Assistant
//

import Foundation
import FoundationModels

/// Provides real-time commentary and analysis of tic-tac-toe games.
///
/// The AI commentator watches the game unfold and provides entertaining
/// play-by-play commentary with strategic insights, similar to a sports announcer.
@MainActor
public final class AICommentator {
    
    // MARK: - Types
    
    /// Style of commentary
    public enum CommentaryStyle {
        case casual      // Friendly, conversational
        case enthusiastic // Excited, sports-announcer style
        case analytical  // Serious, strategy-focused
        case humorous    // Light-hearted and funny
    }
    
    @Generable(description: "Commentary for a tic-tac-toe move")
    public struct Commentary {
        @Guide(description: "Exciting play-by-play commentary (1-2 sentences)")
        public var playByPlay: String
        
        @Guide(description: "Brief strategic insight about the move")
        public var analysis: String
        
        @Guide(description: "Prediction of what might happen next (optional)")
        public var prediction: String?
    }
    
    // MARK: - Properties
    
    private let model = SystemLanguageModel.default
    private var session: LanguageModelSession?
    private let style: CommentaryStyle
    private var gameHistory: [String] = []
    
    // MARK: - Initialization
    
    public init(style: CommentaryStyle = .enthusiastic) {
        self.style = style
    }
    
    // MARK: - Public Methods
    
    /// Checks if the AI commentator is available
    public var isAvailable: Bool {
        switch model.availability {
        case .available:
            return true
        default:
            return false
        }
    }
    
    /// Provides commentary for a move that was just made
    ///
    /// - Parameters:
    ///   - moveIndex: The cell where the move was made
    ///   - board: The current board state (after the move)
    ///   - player: The player who made the move
    /// - Returns: Commentary about the move
    public func commentOnMove(
        _ moveIndex: Int,
        board: GameBoard,
        player: Player
    ) async throws -> Commentary {
        if session == nil {
            session = createSession()
        }
        
        guard let session = session else {
            throw CommentatorError.sessionNotAvailable
        }
        
        let prompt = buildMovePrompt(moveIndex, board: board, player: player)
        
        let response = try await session.respond(
            to: prompt,
            generating: Commentary.self
        )
        
        // Store for context
        gameHistory.append(response.content.playByPlay)
        
        return response.content
    }
    
    /// Provides opening commentary at the start of a game
    public func openingCommentary() async throws -> String {
        if session == nil {
            session = createSession()
        }
        
        guard let session = session else {
            throw CommentatorError.sessionNotAvailable
        }
        
        let prompt = "Provide an exciting opening commentary for a new tic-tac-toe game that's about to begin. Keep it to 1-2 sentences."
        
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    /// Provides closing commentary when the game ends
    ///
    /// - Parameters:
    ///   - board: The final board state
    /// - Returns: Closing commentary about the game result
    public func closingCommentary(for board: GameBoard) async throws -> String {
        if session == nil {
            session = createSession()
        }
        
        guard let session = session else {
            throw CommentatorError.sessionNotAvailable
        }
        
        let result: String
        if let winner = board.winner {
            result = "\(winner.symbol) wins!"
        } else {
            result = "It's a draw!"
        }
        
        let prompt = """
        The tic-tac-toe game has ended: \(result)
        
        Game recap: \(gameHistory.suffix(3).joined(separator: " "))
        
        Provide exciting closing commentary about the game's conclusion in 1-2 sentences.
        """
        
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    /// Provides mid-game analysis commentary
    public func provideMidGameAnalysis(for board: GameBoard) async throws -> String {
        if session == nil {
            session = createSession()
        }
        
        guard let session = session else {
            throw CommentatorError.sessionNotAvailable
        }
        
        let prompt = """
        Mid-game analysis for this tic-tac-toe board:
        \(describeBoardState(board))
        
        Current player: \(board.currentPlayer.symbol)
        Moves made: \(board.moveHistory.count)
        
        Provide brief analysis of the current state of the game and momentum. Keep it to 2 sentences.
        """
        
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    /// Streams commentary in real-time for dynamic updates
    public func streamCommentary(
        for moveIndex: Int,
        board: GameBoard,
        player: Player
    ) -> AsyncThrowingStream<Commentary.PartiallyGenerated, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    if session == nil {
                        session = createSession()
                    }
                    
                    guard let session = session else {
                        throw CommentatorError.sessionNotAvailable
                    }
                    
                    let prompt = buildMovePrompt(moveIndex, board: board, player: player)
                    
                    let stream = session.streamResponse(
                        to: prompt,
                        generating: Commentary.self
                    )
                    
                    for try await snapshot in stream {
                        continuation.yield(snapshot.content)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Resets the commentator's session and history
    public func reset() {
        session = nil
        gameHistory.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func createSession() -> LanguageModelSession {
        let instructions = createInstructions()
        return LanguageModelSession(instructions: instructions)
    }
    
    private func createInstructions() -> String {
        let baseInstructions = """
        You are a tic-tac-toe game commentator.
        Provide entertaining and engaging commentary about moves.
        Keep responses concise and energetic.
        Focus on what makes each move interesting or strategic.
        """
        
        switch style {
        case .casual:
            return baseInstructions + """
            
            Use a friendly, conversational tone.
            Make players feel comfortable and entertained.
            Use casual language like "Nice move!" or "Interesting choice!"
            """
            
        case .enthusiastic:
            return baseInstructions + """
            
            Be excited and energetic like a sports announcer!
            Use exclamations and dramatic language.
            Build tension and excitement with each move.
            Example: "OH! What a brilliant play!" or "This is getting intense!"
            """
            
        case .analytical:
            return baseInstructions + """
            
            Provide serious strategic analysis.
            Focus on tactical implications and game theory.
            Use precise language about positioning and threats.
            Example: "A calculated move to control the diagonal" or "Establishing center dominance"
            """
            
        case .humorous:
            return baseInstructions + """
            
            Be light-hearted and funny!
            Use playful observations and witty remarks.
            Keep it family-friendly but entertaining.
            Example: "Bold move, Cotton!" or "Plot twist incoming!"
            """
        }
    }
    
    private func buildMovePrompt(
        _ moveIndex: Int,
        board: GameBoard,
        player: Player
    ) -> String {
        """
        \(player.symbol) just played at position \(moveIndex).
        
        Current board:
        \(describeBoardState(board))
        
        Move count: \(board.moveHistory.count)
        
        \(gameHistory.isEmpty ? "" : "Previous commentary: \(gameHistory.last!)")
        
        Provide commentary for this move.
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
                    result += "·"
                }
                if col < 2 { result += " " }
            }
            if row < 2 { result += "\n" }
        }
        return result
    }
    
    // MARK: - Error Types
    
    public enum CommentatorError: LocalizedError {
        case sessionNotAvailable
        
        public var errorDescription: String? {
            switch self {
            case .sessionNotAvailable:
                return "Commentary session could not be initialized."
            }
        }
    }
}

// MARK: - SwiftUI Integration Example

#if canImport(SwiftUI)
import SwiftUI

/// View that displays live game commentary
public struct CommentaryView: View {
    @State private var commentator = AICommentator(style: .enthusiastic)
    @State private var currentCommentary: AICommentator.Commentary?
    @State private var streamedCommentary: String = ""
    @State private var isStreaming = false
    
    let board: GameBoard
    let lastMove: Int?
    let lastPlayer: Player?
    
    public init(board: GameBoard, lastMove: Int? = nil, lastPlayer: Player? = nil) {
        self.board = board
        self.lastMove = lastMove
        self.lastPlayer = lastPlayer
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "megaphone.fill")
                    .foregroundStyle(.orange)
                Text("Live Commentary")
                    .font(.headline)
            }
            
            if commentator.isAvailable {
                if isStreaming {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(streamedCommentary)
                            .font(.body)
                            .animation(.easeIn, value: streamedCommentary)
                        
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                } else if let commentary = currentCommentary {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(commentary.playByPlay)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text(commentary.analysis)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        
                        if let prediction = commentary.prediction {
                            Text("↪︎ " + prediction)
                                .font(.caption)
                                .italic()
                                .foregroundStyle(.blue)
                        }
                    }
                } else {
                    Text("Waiting for first move...")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    Text("Commentary requires Apple Intelligence")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .onChange(of: lastMove) { oldValue, newValue in
            if let move = newValue, let player = lastPlayer {
                Task {
                    await commentOnMove(move, player: player)
                }
            }
        }
    }
    
    private func commentOnMove(_ move: Int, player: Player) async {
        do {
            // Option 1: Get full commentary at once
            currentCommentary = try await commentator.commentOnMove(
                move,
                board: board,
                player: player
            )
            
            // Option 2: Stream commentary for dramatic effect (uncomment to use)
            /*
            isStreaming = true
            streamedCommentary = ""
            
            let stream = commentator.streamCommentary(
                for: move,
                board: board,
                player: player
            )
            
            for try await partial in stream {
                if let playByPlay = partial.playByPlay {
                    streamedCommentary = playByPlay
                }
            }
            
            isStreaming = false
            */
        } catch {
            print("Commentary error: \(error)")
        }
    }
}

/// Example showing commentary style picker
public struct CommentaryStylePicker: View {
    @Binding var style: AICommentator.CommentaryStyle
    
    public var body: some View {
        Picker("Commentary Style", selection: $style) {
            Text("Casual").tag(AICommentator.CommentaryStyle.casual)
            Text("Enthusiastic").tag(AICommentator.CommentaryStyle.enthusiastic)
            Text("Analytical").tag(AICommentator.CommentaryStyle.analytical)
            Text("Humorous").tag(AICommentator.CommentaryStyle.humorous)
        }
        .pickerStyle(.segmented)
    }
}
#endif
