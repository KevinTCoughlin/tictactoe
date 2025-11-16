//
//  GameBoard.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import Foundation

/// Represents a player in the tic-tac-toe game.
public enum Player {
    case x
    case o
    
    /// Returns the opposite player.
    var opponent: Player {
        self == .x ? .o : .x
    }
    
    /// Returns the display symbol for this player.
    var symbol: String {
        self == .x ? "X" : "O"
    }
}

/// A tic-tac-toe game board using efficient bitmask representation.
///
/// The board uses 9-bit masks to track each player's moves, where each bit
/// corresponds to a cell in row-major order (0-8). This allows for fast
/// win detection and minimal memory usage.
///
/// Board layout:
/// ```
/// 0 | 1 | 2
/// ---------
/// 3 | 4 | 5
/// ---------
/// 6 | 7 | 8
/// ```
public struct GameBoard {
    
    // MARK: - Types
    
    /// Represents a winning pattern with its bitmask and visual endpoints.
    typealias WinningPattern = (mask: Int, startCell: Int, endCell: Int)
    
    // MARK: - State
    
    /// Bitmask representing X player's occupied cells.
    private(set) var xMask: Int = 0
    
    /// Bitmask representing O player's occupied cells.
    private(set) var oMask: Int = 0
    
    /// The player whose turn it is to move.
    private(set) var currentPlayer: Player = .x
    
    /// The player who made the most recent move.
    private(set) var lastPlayer: Player = .x
    
    // MARK: - Constants
    
    /// All possible winning patterns for a 3×3 board with their visual endpoints.
    ///
    /// Each pattern consists of a bitmask representing the three cells that form
    /// a winning line, along with the start and end cell indices for drawing.
    static let winningPatterns: [WinningPattern] = [
        // Rows
        (mask: 0b111_000_000, startCell: 0, endCell: 2),
        (mask: 0b000_111_000, startCell: 3, endCell: 5),
        (mask: 0b000_000_111, startCell: 6, endCell: 8),
        // Columns
        (mask: 0b100_100_100, startCell: 0, endCell: 6),
        (mask: 0b010_010_010, startCell: 1, endCell: 7),
        (mask: 0b001_001_001, startCell: 2, endCell: 8),
        // Diagonals
        (mask: 0b100_010_001, startCell: 0, endCell: 8),
        (mask: 0b001_010_100, startCell: 2, endCell: 6)
    ]
    
    /// Bitmask representing all nine cells occupied.
    private static let fullBoardMask = 0b111_111_111
    
    // MARK: - Computed Properties
    
    /// A bitmask of all occupied cells (both X and O).
    var occupiedMask: Int {
        xMask | oMask
    }
    
    /// The winning player, if any.
    ///
    /// Returns `.x` or `.o` if that player has achieved a winning pattern,
    /// or `nil` if no player has won yet.
    var winner: Player? {
        for pattern in Self.winningPatterns {
            if hasWinningPattern(mask: xMask, pattern: pattern.mask) {
                return .x
            }
            if hasWinningPattern(mask: oMask, pattern: pattern.mask) {
                return .o
            }
        }
        return nil
    }
    
    /// Returns `true` if the game is a draw (board full with no winner).
    var isDraw: Bool {
        occupiedMask == Self.fullBoardMask && winner == nil
    }
    
    /// Returns `true` if the game has ended (either won or drawn).
    var isGameOver: Bool {
        winner != nil || isDraw
    }
    
    /// The winning line's start and end cell indices, if any.
    ///
    /// Returns a tuple of (startCell, endCell) if there's a winning line,
    /// or `nil` if no player has won yet.
    var winningLine: (startCell: Int, endCell: Int)? {
        for pattern in Self.winningPatterns {
            if hasWinningPattern(mask: xMask, pattern: pattern.mask) ||
               hasWinningPattern(mask: oMask, pattern: pattern.mask) {
                return (pattern.startCell, pattern.endCell)
            }
        }
        return nil
    }
    
    // MARK: - Public Methods
    
    /// Attempts to place a mark for the current player at the specified cell.
    ///
    /// - Parameter index: The cell index (0-8) where the current player wants to move.
    /// - Returns: `true` if the move was legal and applied, `false` otherwise.
    ///
    /// A move is illegal if:
    /// - The index is out of bounds (not 0-8)
    /// - The cell is already occupied
    /// - The game is already over
    @discardableResult
    public mutating func makeMove(at index: Int) -> Bool {
        guard isValidIndex(index) else { return false }
        guard isCellEmpty(at: index) else { return false }
        guard !isGameOver else { return false }
        
        updateMask(for: currentPlayer, at: index)
        advanceTurn()
        
        return true
    }
    
    /// Resets the board to its initial state.
    ///
    /// Clears all moves and sets the current player back to X.
    public mutating func reset() {
        xMask = 0
        oMask = 0
        currentPlayer = .x
        lastPlayer = .x
    }
    
    // MARK: - Private Helpers
    
    /// Returns `true` if the given player mask matches the winning pattern.
    private func hasWinningPattern(mask: Int, pattern: Int) -> Bool {
        (mask & pattern) == pattern
    }
    
    /// Returns `true` if the index is within valid bounds (0-8).
    private func isValidIndex(_ index: Int) -> Bool {
        (0..<9).contains(index)
    }
    
    /// Returns `true` if the cell at the given index is unoccupied.
    private func isCellEmpty(at index: Int) -> Bool {
        let cellBit = bitMask(for: index)
        return (occupiedMask & cellBit) == 0
    }
    
    /// Returns the bitmask for a given cell index.
    ///
    /// Cell 0 maps to bit 8, cell 8 maps to bit 0 (reverse order for readability).
    private func bitMask(for index: Int) -> Int {
        1 << (8 - index)
    }
    
    /// Updates the appropriate player mask with the given move.
    private mutating func updateMask(for player: Player, at index: Int) {
        let cellBit = bitMask(for: index)
        switch player {
        case .x: xMask |= cellBit
        case .o: oMask |= cellBit
        }
    }
    
    /// Advances to the next turn by swapping players.
    private mutating func advanceTurn() {
        lastPlayer = currentPlayer
        currentPlayer = currentPlayer.opponent
    }
}
