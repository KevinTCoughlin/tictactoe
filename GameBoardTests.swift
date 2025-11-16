//
//  GameBoardTests.swift
//  tictactoe Tests
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import XCTest
@testable import tictactoe

/// Comprehensive test suite for GameBoard logic using XCTest.
final class GameBoardTests: XCTestCase {
    
    func testInitialState() {
        let board = GameBoard()
        XCTAssertNil(board.winner, "Initial board should have no winner")
        XCTAssertFalse(board.isDraw, "Initial board should not be a draw")
        XCTAssertFalse(board.isGameOver, "Initial board should not be game over")
        XCTAssertEqual(board.currentPlayer, .x, "Initial player should be X")
    }
    
    func testHorizontalWinTopRow() {
        var board = GameBoard()
        
        // X X X
        // O O -
        // - - -
        board.makeMove(at: 0) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 1) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 2) // X wins
        
        XCTAssertEqual(board.winner, .x, "X should win with top row")
        XCTAssertTrue(board.isGameOver, "Game should be over")
        XCTAssertEqual(board.winningLine?.startCell, 0)
        XCTAssertEqual(board.winningLine?.endCell, 2)
    }
    
    func testHorizontalWinMiddleRow() {
        var board = GameBoard()
        
        // X X -
        // O O O
        // X - -
        board.makeMove(at: 0) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 1) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 6) // X
        board.makeMove(at: 5) // O wins
        
        XCTAssertEqual(board.winner, .o, "O should win with middle row")
        XCTAssertTrue(board.isGameOver, "Game should be over")
        XCTAssertEqual(board.winningLine?.startCell, 3)
        XCTAssertEqual(board.winningLine?.endCell, 5)
    }
    
    func testVerticalWin() {
        var board = GameBoard()
        
        // X O -
        // X O -
        // X - -
        board.makeMove(at: 0) // X
        board.makeMove(at: 1) // O
        board.makeMove(at: 3) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 6) // X wins
        
        XCTAssertEqual(board.winner, .x, "X should win with left column")
        XCTAssertTrue(board.isGameOver, "Game should be over")
        XCTAssertEqual(board.winningLine?.startCell, 0)
        XCTAssertEqual(board.winningLine?.endCell, 6)
    }
    
    func testDiagonalWinTopLeftToBottomRight() {
        var board = GameBoard()
        
        // O X X
        // X O -
        // - - O
        board.makeMove(at: 1) // X
        board.makeMove(at: 0) // O
        board.makeMove(at: 2) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 3) // X
        board.makeMove(at: 8) // O wins
        
        XCTAssertEqual(board.winner, .o, "O should win with diagonal")
        XCTAssertTrue(board.isGameOver, "Game should be over")
        XCTAssertEqual(board.winningLine?.startCell, 0)
        XCTAssertEqual(board.winningLine?.endCell, 8)
    }
    
    func testDiagonalWinTopRightToBottomLeft() {
        var board = GameBoard()
        
        // O O X
        // O X -
        // X - -
        board.makeMove(at: 2) // X
        board.makeMove(at: 0) // O
        board.makeMove(at: 4) // X
        board.makeMove(at: 1) // O
        board.makeMove(at: 6) // X wins
        
        XCTAssertEqual(board.winner, .x, "X should win with diagonal")
        XCTAssertTrue(board.isGameOver, "Game should be over")
        XCTAssertEqual(board.winningLine?.startCell, 2)
        XCTAssertEqual(board.winningLine?.endCell, 6)
    }
    
    func testDrawGame() {
        var board = GameBoard()
        
        // X X O
        // O O X
        // X O X
        let moves = [0, 2, 1, 3, 4, 6, 5, 7, 8]
        moves.forEach { board.makeMove(at: $0) }
        
        XCTAssertTrue(board.isDraw, "Game should be a draw")
        XCTAssertNil(board.winner, "Draw game should have no winner")
        XCTAssertTrue(board.isGameOver, "Game should be over")
    }
    
    func testOccupiedCell() {
        var board = GameBoard()
        
        let firstMove = board.makeMove(at: 0)
        let secondMove = board.makeMove(at: 0)
        
        XCTAssertTrue(firstMove, "First move should succeed")
        XCTAssertFalse(secondMove, "Second move to same cell should fail")
    }
    
    func testCannotMoveAfterGameOver() {
        var board = GameBoard()
        
        // X X X
        // O O -
        // - - -
        board.makeMove(at: 0) // X
        board.makeMove(at: 3) // O
        board.makeMove(at: 1) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 2) // X wins
        
        let moveAfterWin = board.makeMove(at: 5)
        XCTAssertFalse(moveAfterWin, "Move after game over should fail")
    }
    
    func testPlayersAlternate() {
        var board = GameBoard()
        
        XCTAssertEqual(board.currentPlayer, .x, "First player should be X")
        board.makeMove(at: 0)
        XCTAssertEqual(board.currentPlayer, .o, "Second player should be O")
        board.makeMove(at: 1)
        XCTAssertEqual(board.currentPlayer, .x, "Third player should be X")
    }
    
    func testLastPlayerTracking() {
        var board = GameBoard()
        
        XCTAssertEqual(board.lastPlayer, .x, "Initial last player should be X")
        board.makeMove(at: 0)
        XCTAssertEqual(board.lastPlayer, .x, "Last player should be X after X moves")
        board.makeMove(at: 1)
        XCTAssertEqual(board.lastPlayer, .o, "Last player should be O after O moves")
    }
    
    func testResetBoard() {
        var board = GameBoard()
        board.makeMove(at: 0)
        board.makeMove(at: 1)
        board.makeMove(at: 2)
        
        board.reset()
        
        XCTAssertEqual(board.xMask, 0, "X mask should be cleared")
        XCTAssertEqual(board.oMask, 0, "O mask should be cleared")
        XCTAssertEqual(board.currentPlayer, .x, "Current player should be X")
        XCTAssertEqual(board.lastPlayer, .x, "Last player should be X")
        XCTAssertNil(board.winner, "Winner should be nil")
        XCTAssertFalse(board.isDraw, "Should not be a draw")
        XCTAssertFalse(board.isGameOver, "Game should not be over")
    }
    
    func testInvalidIndex() {
        var board = GameBoard()
        
        let negativeIndex = board.makeMove(at: -1)
        let tooLargeIndex = board.makeMove(at: 9)
        
        XCTAssertFalse(negativeIndex, "Negative index should fail")
        XCTAssertFalse(tooLargeIndex, "Too large index should fail")
    }
    
    func testWinningPatternsCount() {
        XCTAssertEqual(GameBoard.winningPatterns.count, 8, "Should have 8 winning patterns")
    }
    
    func testOccupiedMask() {
        var board = GameBoard()
        
        board.makeMove(at: 0) // X
        board.makeMove(at: 4) // O
        board.makeMove(at: 8) // X
        
        // Check that occupied mask has bits set for cells 0, 4, and 8
        let expectedMask = 0b100_010_001
        XCTAssertEqual(board.occupiedMask, expectedMask, "Occupied mask should match expected value")
    }
}
