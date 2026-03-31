//
//  PuzzleSystemTests.swift
//  tictactoeTests
//
//  Created by GitHub Copilot on 11/24/25.
//

import XCTest
import GameplayKit
@testable import tictactoe

/// Unit tests for the puzzle system.
final class PuzzleSystemTests: XCTestCase {
    
    // MARK: - PuzzleModels Tests
    
    func testPuzzleCreation() {
        let puzzle = GamePuzzle(
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b110_000_000,
            oMask: 0b000_110_000,
            currentPlayer: .x,
            solution: [2]
        )
        
        XCTAssertEqual(puzzle.type, .oneMove)
        XCTAssertEqual(puzzle.difficulty, .beginner)
        XCTAssertEqual(puzzle.solution, [2])
        XCTAssertTrue(puzzle.isCorrectMove(2))
        XCTAssertFalse(puzzle.isCorrectMove(1))
    }
    
    func testPuzzleBoardConversion() {
        let puzzle = GamePuzzle(
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b110_000_000,
            oMask: 0b000_110_000,
            currentPlayer: .x,
            solution: [2]
        )
        
        let board = puzzle.board
        
        // Verify X marks
        XCTAssertEqual(board.player(at: 0), .x)
        XCTAssertEqual(board.player(at: 1), .x)
        XCTAssertNil(board.player(at: 2))
        
        // Verify O marks
        XCTAssertEqual(board.player(at: 3), .o)
        XCTAssertEqual(board.player(at: 4), .o)
        
        // Verify current player
        XCTAssertEqual(board.currentPlayer, .x)
    }
    
    func testUserProfileInitialization() {
        let profile = UserPuzzleProfile()
        
        XCTAssertEqual(profile.currentDifficulty, .beginner)
        XCTAssertEqual(profile.currentStreak, 0)
        XCTAssertEqual(profile.totalAttempts, 0)
        XCTAssertEqual(profile.totalSolved, 0)
        XCTAssertEqual(profile.totalPoints, 0)
    }
    
    func testUserProfileStreakTracking() {
        var profile = UserPuzzleProfile()
        
        let puzzle = GamePuzzle(
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b110_000_000,
            oMask: 0b000_110_000,
            currentPlayer: .x,
            solution: [2]
        )
        
        // Record first successful attempt
        profile.recordPuzzleAttempt(puzzle: puzzle, solved: true, timeInSeconds: 10.0)
        
        XCTAssertEqual(profile.currentStreak, 1)
        XCTAssertEqual(profile.longestStreak, 1)
        XCTAssertEqual(profile.totalSolved, 1)
        XCTAssertEqual(profile.totalPoints, puzzle.difficulty.points)
    }
    
    func testUserProfileLevelUp() {
        var profile = UserPuzzleProfile()
        
        let puzzle = GamePuzzle(
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b110_000_000,
            oMask: 0b000_110_000,
            currentPlayer: .x,
            solution: [2]
        )
        
        // Complete 10 puzzles with high success rate
        for _ in 0..<10 {
            profile.recordPuzzleAttempt(puzzle: puzzle, solved: true, timeInSeconds: 10.0)
        }
        
        // Should level up from beginner
        XCTAssertTrue(profile.currentDifficulty == .intermediate || profile.currentDifficulty == .beginner)
    }
    
    func testPuzzleStatistics() {
        var stats = PuzzleStatistics(puzzleId: "test_puzzle")
        
        XCTAssertEqual(stats.attempts, 0)
        XCTAssertEqual(stats.solves, 0)
        XCTAssertFalse(stats.isSolved)
        
        // Record failed attempt
        stats.recordAttempt(solved: false, timeInSeconds: 5.0)
        XCTAssertEqual(stats.attempts, 1)
        XCTAssertEqual(stats.solves, 0)
        
        // Record successful attempt
        stats.recordAttempt(solved: true, timeInSeconds: 10.0)
        XCTAssertEqual(stats.attempts, 2)
        XCTAssertEqual(stats.solves, 1)
        XCTAssertTrue(stats.isSolved)
        XCTAssertEqual(stats.successRate, 50.0)
    }
    
    // MARK: - GameplayKit Integration Tests
    
    func testTicTacToeGameModel() {
        let board = GameBoard()
        let model = TicTacToeGameModel(board: board)
        
        XCTAssertNotNil(model.activePlayer)
        XCTAssertNotNil(model.players)
        XCTAssertEqual(model.players?.count, 2)
    }
    
    func testTicTacToeGameModelMoves() {
        let board = GameBoard()
        let model = TicTacToeGameModel(board: board)
        
        guard let moves = model.gameModelUpdates(for: model.activePlayer!) as? [TicTacToeMove] else {
            XCTFail("Failed to get moves")
            return
        }
        
        // Empty board should have 9 valid moves
        XCTAssertEqual(moves.count, 9)
    }
    
    func testTicTacToeGameModelApplyMove() {
        let board = GameBoard()
        let model = TicTacToeGameModel(board: board)
        
        let move = TicTacToeMove(cellIndex: 0)
        model.apply(move)
        
        let currentBoard = model.currentBoard
        XCTAssertTrue(currentBoard.isCellOccupied(at: 0))
    }
    
    func testPuzzleStrategistFindBestMove() {
        let strategist = PuzzleStrategist()
        
        // Setup a board where X can win
        var board = GameBoard()
        _ = board.makeMove(at: 0) // X
        _ = board.makeMove(at: 3) // O
        _ = board.makeMove(at: 1) // X
        _ = board.makeMove(at: 4) // O
        // X has 0,1 - should play 2 to win
        
        if let bestMove = strategist.findBestMove(for: board) {
            XCTAssertEqual(bestMove, 2)
        } else {
            XCTFail("Should find best move")
        }
    }
    
    func testPuzzleStrategistFindWinningMoves() {
        let strategist = PuzzleStrategist()
        
        // Setup board with winning move
        var board = GameBoard()
        _ = board.makeMove(at: 0) // X
        _ = board.makeMove(at: 3) // O
        _ = board.makeMove(at: 1) // X
        _ = board.makeMove(at: 4) // O
        
        let winningMoves = strategist.findWinningMoves(for: board)
        XCTAssertEqual(winningMoves.count, 1)
        XCTAssertTrue(winningMoves.contains(2))
    }
    
    func testPuzzleStrategistFindBlockingMoves() {
        let strategist = PuzzleStrategist()
        
        // Setup board where O needs to block
        var board = GameBoard()
        _ = board.makeMove(at: 0) // X
        _ = board.makeMove(at: 3) // O
        _ = board.makeMove(at: 1) // X
        // X has 0,1 - O must block at 2
        
        let blockingMoves = strategist.findBlockingMoves(for: board)
        XCTAssertTrue(blockingMoves.contains(2))
    }
    
    // MARK: - PuzzleGenerator Tests
    
    func testPuzzleGeneratorInitialization() {
        let generator = PuzzleGenerator()
        
        // Should have static puzzles loaded
        let puzzle = generator.generatePuzzle(for: UserPuzzleProfile())
        XCTAssertNotNil(puzzle)
    }
    
    func testPuzzleGeneratorDailyPuzzle() {
        let generator = PuzzleGenerator()
        
        let date = Date()
        let puzzle1 = generator.generateDailyPuzzle(for: date)
        let puzzle2 = generator.generateDailyPuzzle(for: date)
        
        // Same date should generate same puzzle
        XCTAssertEqual(puzzle1.id, puzzle2.id)
    }
    
    func testPuzzleGeneratorDifficultyFiltering() {
        let generator = PuzzleGenerator()
        
        var profile = UserPuzzleProfile()
        profile.currentDifficulty = .expert
        
        // Should generate appropriate difficulty puzzle
        let puzzle = generator.generatePuzzle(for: profile)
        XCTAssertNotNil(puzzle)
    }
    
    func testPuzzleValidation() {
        let generator = PuzzleGenerator()
        let results = generator.validateAllPuzzles()
        
        // All static puzzles should be valid
        let invalidPuzzles = results.filter { !$0.value }
        XCTAssertTrue(invalidPuzzles.isEmpty, "Found invalid puzzles: \(invalidPuzzles.keys)")
    }
    
    // MARK: - PuzzleManager Tests
    
    func testPuzzleManagerSingleton() {
        let manager1 = PuzzleManager.shared
        let manager2 = PuzzleManager.shared
        
        XCTAssertTrue(manager1 === manager2)
    }
    
    @MainActor
    func testPuzzleManagerGeneratePuzzle() {
        let manager = PuzzleManager.shared
        let puzzle = manager.generatePuzzle()
        
        XCTAssertNotNil(puzzle)
    }
    
    @MainActor
    func testPuzzleManagerRecordCompletion() {
        let manager = PuzzleManager.shared
        manager.resetProgress() // Start fresh
        
        let puzzle = manager.generatePuzzle()
        manager.recordPuzzleCompletion(puzzle: puzzle, solved: true, timeInSeconds: 15.0)
        
        let stats = manager.getStatistics(for: puzzle.id)
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats?.solves, 1)
    }
    
    @MainActor
    func testPuzzleManagerDailyPuzzle() {
        let manager = PuzzleManager.shared
        let dailyPuzzle = manager.getDailyPuzzle()
        
        XCTAssertNotNil(dailyPuzzle)
        XCTAssertEqual(dailyPuzzle.id, manager.dailyPuzzle?.id)
    }
    
    // MARK: - Integration Tests
    
    func testFullPuzzleFlow() {
        let puzzle = GamePuzzle(
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b110_000_000,
            oMask: 0b000_110_000,
            currentPlayer: .x,
            solution: [2]
        )
        
        // Validate puzzle
        let strategist = PuzzleStrategist()
        let isValid = strategist.validatePuzzle(puzzle)
        XCTAssertTrue(isValid)
        
        // Solve puzzle
        var board = puzzle.board
        let success = board.makeMove(at: puzzle.solution[0])
        XCTAssertTrue(success)
        XCTAssertEqual(board.winner, .x)
    }
    
    func testTwoMovePuzzleFlow() {
        let puzzle = GamePuzzle(
            type: .twoMove,
            difficulty: .advanced,
            xMask: 0b100_010_000,
            oMask: 0b000_000_110,
            currentPlayer: .x,
            solution: [8, 2]
        )
        
        var board = puzzle.board
        
        // Apply first move
        XCTAssertTrue(puzzle.isCorrectMove(puzzle.solution[0]))
        _ = board.makeMove(at: puzzle.solution[0])
        
        // Apply second move
        XCTAssertTrue(puzzle.isCorrectMove(puzzle.solution[1]))
    }
}
