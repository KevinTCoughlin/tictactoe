//
//  NaturalLanguageGameInterface.swift
//  tictactoe Shared
//
//  Created by AI Assistant
//

import Foundation
import FoundationModels

/// Enables playing tic-tac-toe using natural language commands.
///
/// Players can describe moves conversationally (e.g., "top left", "middle",
/// "block their win") and the AI interprets the intent and executes the move.
@MainActor
public final class NaturalLanguageGameInterface {
    
    // MARK: - Types
    
    /// Interpretation of a natural language game command
    @Generable(description: "Interpretation of a natural language game command")
    public struct CommandInterpretation {
        @Guide(description: "The cell index (0-8) the player wants to play")
        public var targetCell: Int
        
        @Guide(description: "Confidence level from 1-10 in this interpretation")
        public var confidence: Int
        
        @Guide(description: "Friendly confirmation message to show the player")
        public var confirmation: String
        
        @Guide(description: "True if the command was unclear and needs clarification")
        public var needsClarification: Bool
        
        @Guide(description: "Clarification question if needed (optional)")
        public var clarificationQuestion: String?
    }
    
    // MARK: - Properties
    
    private let model = SystemLanguageModel.default
    private var session: LanguageModelSession?
    private var conversationHistory: [String] = []
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Checks if natural language interface is available
    public var isAvailable: Bool {
        switch model.availability {
        case .available:
            return true
        default:
            return false
        }
    }
    
    /// Interprets a natural language command and returns the intended move
    ///
    /// - Parameters:
    ///   - command: Natural language input (e.g., "top left", "middle", "block them")
    ///   - board: Current game state
    /// - Returns: Interpretation of the command including target cell
    public func interpretCommand(
        _ command: String,
        for board: GameBoard
    ) async throws -> CommandInterpretation {
        // Create a new session without tools for now
        // The board state will be included in the prompt instead
        session = LanguageModelSession(
            instructions: createInstructions()
        )
        
        guard let session = session else {
            throw InterfaceError.sessionNotAvailable
        }
        
        let prompt = buildPrompt(command: command, board: board)
        
        let response = try await session.respond(
            to: prompt,
            generating: CommandInterpretation.self
        )
        
        conversationHistory.append(command)
        
        return response.content
    }
    
    /// Provides suggestions for what the player could say
    public func getSuggestions(for board: GameBoard) -> [String] {
        var suggestions: [String] = []
        
        // Position-based suggestions
        let availableCells = (0..<9).filter { board.player(at: $0) == nil }
        if availableCells.contains(4) {
            suggestions.append("Play in the middle")
        }
        if [0, 2, 6, 8].contains(where: availableCells.contains) {
            suggestions.append("Take a corner")
        }
        
        // Strategic suggestions
        if board.moveHistory.count > 2 {
            suggestions.append("Block their win")
            suggestions.append("Set up a fork")
        }
        
        // Casual phrases
        suggestions += [
            "Top left",
            "Bottom right",
            "Where should I play?"
        ]
        
        return suggestions
    }
    
    /// Explains why a command was interpreted a certain way
    public func explainInterpretation(
        _ interpretation: CommandInterpretation,
        originalCommand: String
    ) -> String {
        """
        You said: "\(originalCommand)"
        I understood this as: Cell \(interpretation.targetCell)
        Confidence: \(interpretation.confidence)/10
        """
    }
    
    /// Resets the conversation history
    public func reset() {
        session = nil
        conversationHistory.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func createInstructions() -> String {
        """
        You are an AI assistant helping interpret natural language commands for tic-tac-toe.
        
        Your job is to understand what cell the player wants to play in.
        
        Cells are numbered 0-8:
        0 | 1 | 2    (top left, top center, top right)
        ---------
        3 | 4 | 5    (middle left, center, middle right)
        ---------
        6 | 7 | 8    (bottom left, bottom center, bottom right)
        
        Common phrases:
        - "top left" = cell 0
        - "center" or "middle" = cell 4
        - "bottom right" = cell 8
        - "block them" = find where opponent is about to win
        - "win" = find a winning move
        
        If the command is ambiguous, set needsClarification to true.
        Always provide a friendly confirmation message.
        """
    }
    
    private func buildPrompt(command: String, board: GameBoard) -> String {
        var prompt = """
        The player said: "\(command)"
        
        Current player: \(board.currentPlayer.symbol)
        Moves made so far: \(board.moveHistory.count)
        
        Current board state:
        """
        
        // Add board state
        for row in 0..<3 {
            for col in 0..<3 {
                let index = row * 3 + col
                let rowName = ["top", "middle", "bottom"][row]
                let colName = ["left", "center", "right"][col]
                let position = "\(rowName) \(colName)"
                
                if let player = board.player(at: index) {
                    prompt += "\n\(position) (cell \(index)): \(player.symbol)"
                } else {
                    prompt += "\n\(position) (cell \(index)): empty"
                }
            }
        }
        
        prompt += "\n\nInterpret this command and determine which cell (0-8) they want to play."
        
        // Add context from recent conversation
        if !conversationHistory.isEmpty {
            let recentContext = conversationHistory.suffix(3).joined(separator: ", ")
            prompt += "\n\nRecent conversation: \(recentContext)"
        }
        
        return prompt
    }
    
    // MARK: - Error Types
    
    public enum InterfaceError: LocalizedError {
        case sessionNotAvailable
        case commandNotUnderstood
        case invalidCell
        
        public var errorDescription: String? {
            switch self {
            case .sessionNotAvailable:
                return "Natural language interface is not available."
            case .commandNotUnderstood:
                return "I didn't understand that command. Try describing the position you want to play."
            case .invalidCell:
                return "That cell is not available."
            }
        }
    }
}

// MARK: - SwiftUI Integration Example

#if canImport(SwiftUI)
import SwiftUI

/// Chat-style interface for playing tic-tac-toe with natural language
public struct NaturalLanguageGameView: View {
    @State private var board = GameBoard()
    @State private var interface = NaturalLanguageGameInterface()
    @State private var inputText = ""
    @State private var messages: [(text: String, isUser: Bool)] = []
    @State private var isProcessing = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Board display
            VStack(spacing: 16) {
                Text("Tic-Tac-Toe")
                    .font(.title2.bold())
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(0..<9, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .frame(height: 80)
                            
                            Text(board.player(at: index)?.symbol ?? "")
                                .font(.system(size: 40, weight: .bold))
                        }
                    }
                }
                .padding()
                
                if let winner = board.winner {
                    Text("\(winner.symbol) wins!")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else if board.isDraw {
                    Text("It's a draw!")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
            }
            .padding()
            
            Divider()
            
            // Chat interface
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                        ChatBubble(text: message.text, isUser: message.isUser)
                    }
                    
                    if isProcessing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Understanding...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            
            // Input area
            HStack {
                TextField("Say where to play...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isProcessing || board.isGameOver)
                
                Button {
                    Task {
                        await handleCommand()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(inputText.isEmpty || isProcessing || board.isGameOver)
            }
            .padding()
            
            // Suggestions
            if !board.isGameOver {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(interface.getSuggestions(for: board), id: \.self) { suggestion in
                            Button(suggestion) {
                                inputText = suggestion
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            if !interface.isAvailable {
                Text("Requires Apple Intelligence")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            messages.append((
                text: "Welcome! Tell me where you'd like to play. You can say things like 'top left', 'center', or 'block them'.",
                isUser: false
            ))
        }
    }
    
    private func handleCommand() async {
        let command = inputText
        inputText = ""
        
        // Add user message
        messages.append((text: command, isUser: true))
        isProcessing = true
        
        do {
            let interpretation = try await interface.interpretCommand(command, for: board)
            
            if interpretation.needsClarification {
                messages.append((
                    text: interpretation.clarificationQuestion ?? "Could you clarify where you want to play?",
                    isUser: false
                ))
            } else {
                // Make the move
                let success = board.makeMove(at: interpretation.targetCell)
                
                if success {
                    messages.append((text: interpretation.confirmation, isUser: false))
                    
                    if board.isGameOver {
                        if let winner = board.winner {
                            messages.append((text: "Game over! \(winner.symbol) wins!", isUser: false))
                        } else {
                            messages.append((text: "Game over! It's a draw!", isUser: false))
                        }
                    }
                } else {
                    messages.append((
                        text: "That cell is already taken. Try another position.",
                        isUser: false
                    ))
                }
            }
        } catch {
            messages.append((
                text: "I didn't quite understand that. Could you try rephrasing?",
                isUser: false
            ))
        }
        
        isProcessing = false
    }
}

struct ChatBubble: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(text)
                .padding(12)
                .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
            
            if !isUser { Spacer() }
        }
    }
}
#endif
