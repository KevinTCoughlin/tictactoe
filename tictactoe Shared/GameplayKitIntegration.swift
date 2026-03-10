//
//  GameplayKitIntegration.swift
//  tictactoe Shared
//
//  Created by GitHub Copilot on 11/24/25.
//

import Foundation
import GameplayKit

// MARK: - TicTacToePlayer

/// Represents a player in the GKGameModel protocol.
///
/// This wrapper allows our Player enum to work with GameplayKit's strategist.
final class TicTacToePlayer: NSObject, GKGameModelPlayer {
    
    /// Unique identifier for this player (0 for X, 1 for O)
    let playerId: Int
    
    /// The underlying Player enum
    let player: Player
    
    init(player: Player) {
        self.player = player
        self.playerId = player == .x ? 0 : 1
        super.init()
    }
}

// MARK: - TicTacToeMove

/// Represents a move in the GKGameModel protocol.
///
/// Encapsulates a cell index where a player wants to place their mark.
final class TicTacToeMove: NSObject, GKGameModelUpdate {
    
    /// The cell index (0-8) where the move is made
    let cellIndex: Int
    
    /// Value used by strategist for move ordering (higher is better)
    var value: Int = 0
    
    init(cellIndex: Int) {
        self.cellIndex = cellIndex
        super.init()
    }
}

// MARK: - TicTacToeGameModel

/// A GameplayKit-compatible model of the tic-tac-toe game.
///
/// This class enables the use of GKMinmaxStrategist for intelligent move
/// analysis, which is crucial for puzzle validation and ML training data generation.
final class TicTacToeGameModel: NSObject, GKGameModel {
    
    // MARK: - Properties
    
    /// The underlying game board
    private var board: GameBoard
    
    /// Players in the game
    private let players: [TicTacToePlayer]
    
    /// Active player (whose turn it is)
    var activePlayer: GKGameModelPlayer? {
        players.first { $0.player == board.currentPlayer }
    }
    
    // MARK: - Initialization
    
    /// Creates a new game model with the specified board state
    init(board: GameBoard = GameBoard()) {
        self.board = board
        self.players = [
            TicTacToePlayer(player: .x),
            TicTacToePlayer(player: .o)
        ]
        super.init()
    }
    
    // MARK: - GKGameModel Protocol
    
    /// Returns all players in the game
    var players: [GKGameModelPlayer]? {
        players.map { $0 as GKGameModelPlayer }
    }
    
    /// Returns array of valid moves for the current player
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // Game over - no valid moves
        guard !board.isGameOver else { return nil }
        
        // Ensure it's the correct player's turn
        guard let tttPlayer = player as? TicTacToePlayer,
              tttPlayer.player == board.currentPlayer else {
            return nil
        }
        
        // Return all empty cells as valid moves
        var moves: [TicTacToeMove] = []
        for cellIndex in 0..<9 {
            if !board.isCellOccupied(at: cellIndex) {
                moves.append(TicTacToeMove(cellIndex: cellIndex))
            }
        }
        
        return moves
    }
    
    /// Applies a move to the game model
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move = gameModelUpdate as? TicTacToeMove else { return }
        _ = board.makeMove(at: move.cellIndex)
    }
    
    /// Reverses a move (required for minimax algorithm)
    func unapplyGameModelUpdate(_ gameModelUpdate: GKGameModelUpdate) {
        // For minimax to work efficiently, we would need to undo moves.
        // Since our GameBoard uses immutable properties, we handle this by
        // making copies before applying moves in the strategist.
        // This is acceptable for tic-tac-toe's small state space.
        
        // Note: GKMinmaxStrategist will use copy() to create snapshots,
        // so we don't need explicit undo functionality.
    }
    
    /// Creates a deep copy of the game model
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TicTacToeGameModel(board: board)
        return copy
    }
    
    /// Sets the game state from another model
    func setGameModel(_ gameModel: GKGameModel) {
        guard let other = gameModel as? TicTacToeGameModel else { return }
        self.board = other.board
    }
    
    /// Scores the current board state for the given player
    ///
    /// Returns:
    /// - 1000 if player has won
    /// - -1000 if opponent has won
    /// - 0 if draw or game in progress
    func score(for player: GKGameModelPlayer) -> Int {
        guard let tttPlayer = player as? TicTacToePlayer else { return 0 }
        
        if let winner = board.winner {
            if winner == tttPlayer.player {
                return 1000 // Win
            } else {
                return -1000 // Loss
            }
        }
        
        if board.isDraw {
            return 0 // Draw
        }
        
        // Game still in progress - could add heuristics here
        return evaluatePosition(for: tttPlayer.player)
    }
    
    /// Returns whether the game is over
    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let tttPlayer = player as? TicTacToePlayer else { return false }
        return board.winner == tttPlayer.player
    }
    
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        guard let tttPlayer = player as? TicTacToePlayer else { return false }
        return board.winner == tttPlayer.player.opponent
    }
    
    // MARK: - Helper Methods
    
    /// Evaluates the board position for strategic value
    ///
    /// This heuristic helps the AI make better decisions in non-terminal positions.
    /// It considers:
    /// - Potential winning lines
    /// - Center control
    /// - Corner control
    private func evaluatePosition(for player: Player) -> Int {
        var score = 0
        
        // Favor center control
        if board.player(at: 4) == player {
            score += 3
        } else if board.player(at: 4) == player.opponent {
            score -= 3
        }
        
        // Favor corner control
        let corners = [0, 2, 6, 8]
        for corner in corners {
            if board.player(at: corner) == player {
                score += 2
            } else if board.player(at: corner) == player.opponent {
                score -= 2
            }
        }
        
        return score
    }
    
    /// Returns the current board state
    var currentBoard: GameBoard {
        board
    }
}

// MARK: - PuzzleStrategist

/// Wrapper around GKMinmaxStrategist for puzzle analysis.
///
/// This class provides high-level methods for analyzing positions,
/// finding optimal moves, and validating puzzle solutions.
final class PuzzleStrategist {
    
    // MARK: - Properties
    
    /// The GameplayKit strategist for move analysis
    private let strategist: GKMinmaxStrategist
    
    /// Maximum lookahead depth for move analysis
    var maxLookAheadDepth: Int {
        get { strategist.maxLookAheadDepth }
        set { strategist.maxLookAheadDepth = newValue }
    }
    
    // MARK: - Initialization
    
    init(maxLookAheadDepth: Int = 9) {
        self.strategist = GKMinmaxStrategist()
        self.strategist.maxLookAheadDepth = maxLookAheadDepth
        self.strategist.randomSource = nil // Deterministic results
    }
    
    // MARK: - Analysis Methods
    
    /// Finds the best move for the current player in the given position
    ///
    /// - Parameter board: The current board state
    /// - Returns: The cell index of the best move, or nil if game is over
    func findBestMove(for board: GameBoard) -> Int? {
        let model = TicTacToeGameModel(board: board)
        strategist.gameModel = model
        
        guard let move = strategist.bestMove(for: model.activePlayer!) as? TicTacToeMove else {
            return nil
        }
        
        return move.cellIndex
    }
    
    /// Finds all winning moves in one turn for the current player
    ///
    /// - Parameter board: The current board state
    /// - Returns: Array of cell indices that lead to immediate victory
    func findWinningMoves(for board: GameBoard) -> [Int] {
        var winningMoves: [Int] = []
        
        // Test each empty cell
        for cellIndex in 0..<9 {
            guard !board.isCellOccupied(at: cellIndex) else { continue }
            
            // Try making the move
            var testBoard = board
            guard testBoard.makeMove(at: cellIndex) else { continue }
            
            // Check if this move wins
            if testBoard.winner == board.currentPlayer {
                winningMoves.append(cellIndex)
            }
        }
        
        return winningMoves
    }
    
    /// Finds all blocking moves that prevent opponent's immediate win
    ///
    /// - Parameter board: The current board state
    /// - Returns: Array of cell indices that block opponent's winning move
    func findBlockingMoves(for board: GameBoard) -> [Int] {
        var blockingMoves: [Int] = []
        
        // Check opponent's winning moves
        var opponentBoard = board
        opponentBoard.currentPlayer = board.currentPlayer.opponent
        
        let opponentWinningMoves = findWinningMoves(for: opponentBoard)
        
        // These cells must be blocked
        return opponentWinningMoves
    }
    
    /// Analyzes if a sequence of moves leads to a guaranteed win
    ///
    /// - Parameters:
    ///   - board: The starting board state
    ///   - moves: Sequence of moves to analyze
    /// - Returns: true if the sequence guarantees a win
    func analyzeMoveSequence(board: GameBoard, moves: [Int]) -> Bool {
        var testBoard = board
        
        // Apply each move
        for move in moves {
            guard testBoard.makeMove(at: move) else { return false }
            
            // If we won, sequence is valid
            if testBoard.winner == board.currentPlayer {
                return true
            }
            
            // If opponent can win on their turn, sequence fails
            if !findWinningMoves(for: testBoard).isEmpty {
                // Opponent has a winning move - our sequence didn't work
                return false
            }
            
            // Apply opponent's best response
            if let opponentMove = findBestMove(for: testBoard) {
                guard testBoard.makeMove(at: opponentMove) else { return false }
                
                // If opponent won, sequence fails
                if testBoard.winner != nil && testBoard.winner != board.currentPlayer {
                    return false
                }
            }
        }
        
        return false
    }
    
    /// Evaluates the difficulty of finding the best move in a position
    ///
    /// This can be used to automatically classify puzzle difficulty.
    ///
    /// - Parameter board: The board state to evaluate
    /// - Returns: Estimated difficulty level
    func estimateDifficulty(for board: GameBoard) -> PuzzleDifficulty {
        // Count the number of equally good moves
        let model = TicTacToeGameModel(board: board)
        strategist.gameModel = model
        
        guard let bestMove = strategist.bestMove(for: model.activePlayer!) as? TicTacToeMove else {
            return .beginner
        }
        
        // Get all valid moves
        guard let allMoves = model.gameModelUpdates(for: model.activePlayer!) as? [TicTacToeMove] else {
            return .beginner
        }
        
        // Count how many moves have similar scores to the best move
        let bestScore = bestMove.value
        let similarMoves = allMoves.filter { abs($0.value - bestScore) <= 100 }
        
        // More similar moves = harder to find the right one
        let movesCount = similarMoves.count
        let totalMoves = allMoves.count
        
        // Also consider how full the board is
        let occupiedCells = (0..<9).filter { board.isCellOccupied(at: $0) }.count
        
        if movesCount == 1 && occupiedCells >= 6 {
            return .expert
        } else if movesCount <= 2 && occupiedCells >= 5 {
            return .advanced
        } else if movesCount <= 3 && occupiedCells >= 4 {
            return .intermediate
        } else {
            return .beginner
        }
    }
    
    /// Validates that a puzzle has a valid solution
    ///
    /// - Parameter puzzle: The puzzle to validate
    /// - Returns: true if puzzle is solvable and solution is correct
    func validatePuzzle(_ puzzle: GamePuzzle) -> Bool {
        let board = puzzle.board
        
        switch puzzle.type {
        case .oneMove:
            // Validate there is exactly one winning move
            let winningMoves = findWinningMoves(for: board)
            return winningMoves.count == 1 && puzzle.isCorrectMove(winningMoves[0])
            
        case .twoMove:
            // Validate the two-move sequence leads to a win
            guard puzzle.solution.count == 2 else { return false }
            return analyzeMoveSequence(board: board, moves: puzzle.solution)
            
        case .defensive:
            // Validate blocking move prevents opponent's win
            let blockingMoves = findBlockingMoves(for: board)
            return !blockingMoves.isEmpty && puzzle.solution.allSatisfy { blockingMoves.contains($0) }
        }
    }
}
