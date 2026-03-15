//
//  GameBoardTests.swift
//  tictactoe Tests
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import Testing
@testable import tictactoe

@Suite("GameBoard Tests")
struct GameBoardTests {
    
    // MARK: - Initial State Tests
    
    @Test("Initial state has no winner")
    func initialState() {
        let board = GameBoard()
        
        #expect(board.winner == nil)
        #expect(board.isDraw == false)
        #expect(board.isGameOver == false)
        #expect(board.currentPlayer == .x)
        #expect(board.xMask == 0)
        #expect(board.oMask == 0)
        #expect(board.occupiedMask == 0)
    }
    
    @Test("Initial board has no marks")
    func initialBoardEmpty() {
        let board = GameBoard()
        
        for i in 0..<9 {
            #expect(board.player(at: i) == nil)
            #expect(!board.isCellOccupied(at: i))
        }
    }
    
    // MARK: - Move Tests
    
    @Test("First move is by player X")
    func firstMove() {
        var board = GameBoard()
        
        let success = board.makeMove(at: 0)
        
        #expect(success == true)
        #expect(board.player(at: 0) == .x)
        #expect(board.currentPlayer == .o)
        #expect(board.lastPlayer == .x)
    }
    
    @Test("Players alternate turns")
    func alternatingTurns() {
        var board = GameBoard()
        
        board.makeMove(at: 0) // X
        #expect(board.currentPlayer == .o)
        
        board.makeMove(at: 1) // O
        #expect(board.currentPlayer == .x)
        
        board.makeMove(at: 2) // X
        #expect(board.currentPlayer == .o)
    }
    
    @Test("Cannot move on occupied cell")
    func occupiedCell() {
        var board = GameBoard()
        
        let firstMove = board.makeMove(at: 0)
        let secondMove = board.makeMove(at: 0)
        
        #expect(firstMove == true)
        #expect(secondMove == false)
        #expect(board.player(at: 0) == .x)
    }
    
    @Test("Cannot move on invalid index")
    func invalidIndex() {
        var board = GameBoard()
        
        #expect(!board.makeMove(at: -1))
        #expect(!board.makeMove(at: 9))
        #expect(!board.makeMove(at: 100))
    }
    
    @Test("Cannot move after game is over")
    func moveAfterGameOver() {
        var board = GameBoard()
        
        // Create winning position for X
        // X X X
        // O O -
        // - - -
        board.makeMove(at: 0) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 1) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 2) // X wins
        
        #expect(board.isGameOver == true)
        #expect(!board.makeMove(at: 5))
    }
    
    // MARK: - Horizontal Win Tests
    
    @Test("Player X wins horizontally - top row")
    func xWinsTopRow() {
        var board = GameBoard()
        
        // X X X
        // O O -
        // - - -
        board.makeMove(at: 0) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 1) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 2) // X wins
        
        #expect(board.winner == .x)
        #expect(board.isGameOver == true)
        #expect(board.winningLine?.startCell == 0)
        #expect(board.winningLine?.endCell == 2)
    }
    
    @Test("Player O wins horizontally - middle row")
    func oWinsMiddleRow() {
        var board = GameBoard()
        
        // X X -
        // O O O
        // - - X
        board.makeMove(at: 0) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 1) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 8) // X
        board.makeMove(at: 5) // O wins
        
        #expect(board.winner == .o)
        #expect(board.isGameOver == true)
        #expect(board.winningLine?.startCell == 3)
        #expect(board.winningLine?.endCell == 5)
    }
    
    @Test("Player X wins horizontally - bottom row")
    func xWinsBottomRow() {
        var board = GameBoard()
        
        // O O -
        // - - -
        // X X X
        board.makeMove(at: 6) // X
        board.makeMove(at: 0) // O
        board.makeMove(at: 7) // X
        board.makeMove(at: 1) // O
        board.makeMove(at: 8) // X wins
        
        #expect(board.winner == .x)
        #expect(board.winningLine?.startCell == 6)
        #expect(board.winningLine?.endCell == 8)
    }
    
    // MARK: - Vertical Win Tests
    
    @Test("Player X wins vertically - left column")
    func xWinsLeftColumn() {
        var board = GameBoard()
        
        // X O -
        // X O -
        // X - -
        board.makeMove(at: 0) // X
        board.makeMove(at: 1) // O
        board.makeMove(at: 3) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 6) // X wins
        
        #expect(board.winner == .x)
        #expect(board.winningLine?.startCell == 0)
        #expect(board.winningLine?.endCell == 6)
    }
    
    @Test("Player O wins vertically - middle column")
    func oWinsMiddleColumn() {
        var board = GameBoard()
        
        // X O -
        // - O X
        // - O X
        board.makeMove(at: 0) // X
        board.makeMove(at: 1) // O
        board.makeMove(at: 5) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 8) // X
        board.makeMove(at: 7) // O wins
        
        #expect(board.winner == .o)
        #expect(board.winningLine?.startCell == 1)
        #expect(board.winningLine?.endCell == 7)
    }
    
    @Test("Player X wins vertically - right column")
    func xWinsRightColumn() {
        var board = GameBoard()
        
        // O - X
        // O - X
        // - - X
        board.makeMove(at: 2) // X
        board.makeMove(at: 0) // O
        board.makeMove(at: 5) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 8) // X wins
        
        #expect(board.winner == .x)
        #expect(board.winningLine?.startCell == 2)
        #expect(board.winningLine?.endCell == 8)
    }
    
    // MARK: - Diagonal Win Tests
    
    @Test("Player X wins diagonally - top-left to bottom-right")
    func xWinsDiagonalTLBR() {
        var board = GameBoard()
        
        // X O -
        // O X -
        // - - X
        board.makeMove(at: 0) // X
        board.makeMove(at: 1) // O
        board.makeMove(at: 4) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 8) // X wins
        
        #expect(board.winner == .x)
        #expect(board.winningLine?.startCell == 0)
        #expect(board.winningLine?.endCell == 8)
    }
    
    @Test("Player O wins diagonally - top-right to bottom-left")
    func oWinsDiagonalTRBL() {
        var board = GameBoard()
        
        // X X O
        // - O -
        // O X X
        board.makeMove(at: 0) // X
        board.makeMove(at: 2) // O
        board.makeMove(at: 1) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 7) // X
        board.makeMove(at: 6) // O wins
        
        #expect(board.winner == .o)
        #expect(board.winningLine?.startCell == 2)
        #expect(board.winningLine?.endCell == 6)
    }
    
    // MARK: - Draw Tests
    
    @Test("Draw game - no winner")
    func drawGame() {
        var board = GameBoard()
        
        // X X O
        // O O X
        // X O X
        let moves = [0, 2, 1, 3, 4, 6, 5, 7, 8]
        for move in moves {
            board.makeMove(at: move)
        }
        
        #expect(board.isDraw == true)
        #expect(board.winner == nil)
        #expect(board.isGameOver == true)
    }
    
    @Test("Draw game - alternative pattern")
    func drawGameAlternative() {
        var board = GameBoard()
        
        // X O X
        // X O O
        // O X X
        let moves = [0, 1, 2, 4, 3, 5, 7, 6, 8]
        for move in moves {
            board.makeMove(at: move)
        }
        
        #expect(board.isDraw == true)
        #expect(board.winner == nil)
        #expect(board.isGameOver == true)
    }
    
    // MARK: - Reset Tests
    
    @Test("Reset clears board")
    func resetBoard() {
        var board = GameBoard()
        
        // Make some moves
        board.makeMove(at: 0)
        board.makeMove(at: 1)
        board.makeMove(at: 4)
        
        // Reset
        board.reset()
        
        #expect(board.xMask == 0)
        #expect(board.oMask == 0)
        #expect(board.currentPlayer == .x)
        #expect(board.lastPlayer == .x)
        #expect(board.winner == nil)
        #expect(board.isDraw == false)
        #expect(board.isGameOver == false)
    }
    
    @Test("Reset after win allows new game")
    func resetAfterWin() {
        var board = GameBoard()
        
        // Create winning position
        board.makeMove(at: 0) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 1) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 2) // X wins
        
        #expect(board.isGameOver == true)
        
        // Reset and play again
        board.reset()
        
        #expect(board.isGameOver == false)
        #expect(board.makeMove(at: 0) == true)
    }
    
    // MARK: - Query Tests
    
    @Test("Can query cell occupancy")
    func queryCellOccupancy() {
        var board = GameBoard()
        
        board.makeMove(at: 0) // X
        board.makeMove(at: 4) // O
        
        #expect(board.isCellOccupied(at: 0) == true)
        #expect(board.isCellOccupied(at: 4) == true)
        #expect(board.isCellOccupied(at: 1) == false)
        #expect(board.isCellOccupied(at: 8) == false)
    }
    
    @Test("Can query player at cell")
    func queryPlayerAtCell() {
        var board = GameBoard()
        
        board.makeMove(at: 0) // X
        board.makeMove(at: 4) // O
        
        #expect(board.player(at: 0) == .x)
        #expect(board.player(at: 4) == .o)
        #expect(board.player(at: 1) == nil)
        #expect(board.player(at: 8) == nil)
    }
    
    // MARK: - Player Tests
    
    @Test("Player X has correct symbol")
    func playerXSymbol() {
        #expect(Player.x.symbol == "X")
    }
    
    @Test("Player O has correct symbol")
    func playerOSymbol() {
        #expect(Player.o.symbol == "O")
    }
    
    @Test("Player opponents are correct")
    func playerOpponents() {
        #expect(Player.x.opponent == .o)
        #expect(Player.o.opponent == .x)
    }
}
