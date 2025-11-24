//
//  PuzzleModels.swift
//  tictactoe Shared
//
//  Created by GitHub Copilot on 11/24/25.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#endif

// MARK: - PuzzleType

/// Represents the type of puzzle challenge.
public enum PuzzleType: String, Codable, CaseIterable {
    /// Find the winning move in one turn
    case oneMove = "one_move_win"
    
    /// Find the sequence to win in two turns
    case twoMove = "two_move_win"
    
    /// Find the defensive move to prevent opponent's win
    case defensive = "defensive"
    
    /// Display name for UI
    public var displayName: String {
        switch self {
        case .oneMove: return "Win in One"
        case .twoMove: return "Win in Two"
        case .defensive: return "Defend"
        }
    }
    
    /// Description of what the puzzle asks
    public var instruction: String {
        switch self {
        case .oneMove: return "Find the winning move!"
        case .twoMove: return "Find the sequence to win in two moves"
        case .defensive: return "Block your opponent's winning move!"
        }
    }
}

// MARK: - PuzzleDifficulty

/// Represents the difficulty level of a puzzle.
public enum PuzzleDifficulty: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
    case expert
    
    /// Points awarded for solving puzzle at this difficulty
    public var points: Int {
        switch self {
        case .beginner: return 10
        case .intermediate: return 25
        case .advanced: return 50
        case .expert: return 100
        }
    }
}

// MARK: - GamePuzzle

/// Represents a tic-tac-toe puzzle challenge.
///
/// A puzzle consists of a board state where the player must find the optimal move(s).
/// The puzzle includes both the scenario and solution for validation.
public struct GamePuzzle: Codable, Identifiable {
    
    // MARK: - Properties
    
    /// Unique identifier for the puzzle
    public let id: String
    
    /// Type of puzzle (one-move, two-move, defensive)
    public let type: PuzzleType
    
    /// Difficulty level
    public let difficulty: PuzzleDifficulty
    
    /// Bitmask representing X player's occupied cells
    public let xMask: Int
    
    /// Bitmask representing O player's occupied cells
    public let oMask: Int
    
    /// The player who needs to make the next move
    public let currentPlayer: Player
    
    /// The correct solution move(s) - cell indices
    public let solution: [Int]
    
    /// Optional hint text
    public let hint: String?
    
    /// Tags for categorization (e.g., "corner_trap", "fork")
    public let tags: [String]
    
    /// When this puzzle was created (for ML training data)
    public let createdAt: Date
    
    /// Source of the puzzle (static, ml_generated, user_submitted)
    public let source: PuzzleSource
    
    // MARK: - Initialization
    
    public init(
        id: String = UUID().uuidString,
        type: PuzzleType,
        difficulty: PuzzleDifficulty,
        xMask: Int,
        oMask: Int,
        currentPlayer: Player,
        solution: [Int],
        hint: String? = nil,
        tags: [String] = [],
        createdAt: Date = Date(),
        source: PuzzleSource = .static
    ) {
        self.id = id
        self.type = type
        self.difficulty = difficulty
        self.xMask = xMask
        self.oMask = oMask
        self.currentPlayer = currentPlayer
        self.solution = solution
        self.hint = hint
        self.tags = tags
        self.createdAt = createdAt
        self.source = source
    }
    
    // MARK: - Computed Properties
    
    /// Creates a GameBoard instance from this puzzle state
    public var board: GameBoard {
        var gameBoard = GameBoard()
        // Reconstruct the board from bitmasks
        for cellIndex in 0..<9 {
            let bitMask = 1 << (8 - cellIndex)
            if (xMask & bitMask) != 0 {
                // Place X
                var tempBoard = gameBoard
                tempBoard.currentPlayer = .x
                _ = tempBoard.makeMove(at: cellIndex)
                gameBoard = tempBoard
            } else if (oMask & bitMask) != 0 {
                // Place O
                var tempBoard = gameBoard
                tempBoard.currentPlayer = .o
                _ = tempBoard.makeMove(at: cellIndex)
                gameBoard = tempBoard
            }
        }
        // Ensure current player is set correctly
        var finalBoard = gameBoard
        finalBoard.currentPlayer = currentPlayer
        return finalBoard
    }
    
    /// Validates if a move is part of the correct solution
    public func isCorrectMove(_ move: Int) -> Bool {
        solution.contains(move)
    }
    
    /// First move in the solution sequence
    public var firstMove: Int? {
        solution.first
    }
}

// MARK: - PuzzleSource

/// Indicates the source/origin of a puzzle.
public enum PuzzleSource: String, Codable {
    /// Hand-crafted static puzzle
    case `static`
    
    /// Generated by ML model
    case mlGenerated = "ml_generated"
    
    /// Submitted by a user
    case userSubmitted = "user_submitted"
    
    /// Derived from actual game play
    case gamePlay = "game_play"
}

// MARK: - PuzzleStatistics

/// Tracks statistics for a specific puzzle.
public struct PuzzleStatistics: Codable {
    
    // MARK: - Properties
    
    /// The puzzle ID this statistics entry is for
    public let puzzleId: String
    
    /// Number of times this puzzle was attempted
    public var attempts: Int
    
    /// Number of times this puzzle was solved correctly
    public var solves: Int
    
    /// Average time to solve (in seconds)
    public var averageTimeToSolve: Double
    
    /// Last attempt date
    public var lastAttemptDate: Date?
    
    /// Last solve date
    public var lastSolveDate: Date?
    
    /// User rating (1-5 stars, optional)
    public var userRating: Int?
    
    // MARK: - Initialization
    
    public init(puzzleId: String) {
        self.puzzleId = puzzleId
        self.attempts = 0
        self.solves = 0
        self.averageTimeToSolve = 0
        self.lastAttemptDate = nil
        self.lastSolveDate = nil
        self.userRating = nil
    }
    
    // MARK: - Computed Properties
    
    /// Success rate percentage (0-100)
    public var successRate: Double {
        guard attempts > 0 else { return 0 }
        return (Double(solves) / Double(attempts)) * 100
    }
    
    /// Whether this puzzle has been solved at least once
    public var isSolved: Bool {
        solves > 0
    }
    
    // MARK: - Methods
    
    /// Records an attempt with the time taken
    public mutating func recordAttempt(solved: Bool, timeInSeconds: Double) {
        attempts += 1
        lastAttemptDate = Date()
        
        if solved {
            solves += 1
            lastSolveDate = Date()
            
            // Update average time using incremental mean calculation
            let totalTime = averageTimeToSolve * Double(solves - 1)
            averageTimeToSolve = (totalTime + timeInSeconds) / Double(solves)
        }
    }
}

// MARK: - UserPuzzleProfile

/// Tracks a user's overall puzzle progress and performance.
///
/// This data can be used for difficulty progression and as training data
/// for ML models to generate personalized puzzles.
public struct UserPuzzleProfile: Codable {
    
    // MARK: - Properties
    
    /// User's current difficulty level
    public var currentDifficulty: PuzzleDifficulty
    
    /// Current streak of consecutive daily puzzles solved
    public var currentStreak: Int
    
    /// Longest streak achieved
    public var longestStreak: Int
    
    /// Total puzzles attempted
    public var totalAttempts: Int
    
    /// Total puzzles solved
    public var totalSolved: Int
    
    /// Total points earned
    public var totalPoints: Int
    
    /// Last puzzle completion date (for streak tracking)
    public var lastCompletionDate: Date?
    
    /// Statistics for individual puzzles
    public var puzzleStats: [String: PuzzleStatistics]
    
    /// Puzzle type preferences (for ML personalization)
    public var typePreferences: [PuzzleType: Int]
    
    /// Average solve times by difficulty
    public var averageSolveTimes: [PuzzleDifficulty: Double]
    
    /// Count of solved puzzles by difficulty (for efficient average calculations)
    private var solvedCountsByDifficulty: [PuzzleDifficulty: Int]
    
    /// User preferences for notification timing
    public var preferredNotificationHour: Int
    
    // MARK: - Initialization
    
    public init() {
        self.currentDifficulty = .beginner
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalAttempts = 0
        self.totalSolved = 0
        self.totalPoints = 0
        self.lastCompletionDate = nil
        self.puzzleStats = [:]
        self.typePreferences = [:]
        self.averageSolveTimes = [:]
        self.solvedCountsByDifficulty = [:]
        self.preferredNotificationHour = 9 // 9 AM default
    }
    
    // MARK: - Computed Properties
    
    /// Overall success rate percentage
    public var successRate: Double {
        guard totalAttempts > 0 else { return 0 }
        return (Double(totalSolved) / Double(totalAttempts)) * 100
    }
    
    /// Whether user should level up to next difficulty
    public var shouldLevelUp: Bool {
        // Level up criteria: solve rate > 80% for current difficulty with at least 10 attempts
        guard totalAttempts >= 10 else { return false }
        guard successRate >= 80 else { return false }
        
        // Check if already at max difficulty
        guard currentDifficulty != .expert else { return false }
        
        return true
    }
    
    /// Whether streak is still active (completed puzzle within last 48 hours)
    public var isStreakActive: Bool {
        guard let lastDate = lastCompletionDate else { return false }
        let hoursSinceLastCompletion = Date().timeIntervalSince(lastDate) / 3600
        return hoursSinceLastCompletion <= 48
    }
    
    // MARK: - Methods
    
    /// Records a puzzle attempt
    public mutating func recordPuzzleAttempt(
        puzzle: GamePuzzle,
        solved: Bool,
        timeInSeconds: Double
    ) {
        totalAttempts += 1
        
        if solved {
            totalSolved += 1
            totalPoints += puzzle.difficulty.points
            
            // Update type preferences
            typePreferences[puzzle.type, default: 0] += 1
            
            // Update average solve time for difficulty efficiently using maintained counter
            let currentAvg = averageSolveTimes[puzzle.difficulty, default: 0]
            let currentCount = solvedCountsByDifficulty[puzzle.difficulty, default: 0]
            averageSolveTimes[puzzle.difficulty] = 
                (currentAvg * Double(currentCount) + timeInSeconds) / Double(currentCount + 1)
            
            // Increment solved count for this difficulty
            solvedCountsByDifficulty[puzzle.difficulty, default: 0] += 1
            
            // Update streak
            updateStreak()
        }
        
        // Update puzzle-specific stats
        var stats = puzzleStats[puzzle.id] ?? PuzzleStatistics(puzzleId: puzzle.id)
        stats.recordAttempt(solved: solved, timeInSeconds: timeInSeconds)
        puzzleStats[puzzle.id] = stats
        
        // Check for level up
        if shouldLevelUp {
            levelUp()
        }
    }
    
    /// Updates the current streak based on completion timing
    private mutating func updateStreak() {
        let now = Date()
        
        if let lastDate = lastCompletionDate {
            let hoursSinceLastCompletion = now.timeIntervalSince(lastDate) / 3600
            
            if hoursSinceLastCompletion <= 48 {
                // Streak continues
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                // Streak broken
                currentStreak = 1
            }
        } else {
            // First puzzle
            currentStreak = 1
            longestStreak = 1
        }
        
        lastCompletionDate = now
    }
    
    /// Levels up the user to the next difficulty
    private mutating func levelUp() {
        switch currentDifficulty {
        case .beginner:
            currentDifficulty = .intermediate
        case .intermediate:
            currentDifficulty = .advanced
        case .advanced:
            currentDifficulty = .expert
        case .expert:
            break // Already at max
        }
    }
    
    /// Resets the streak (e.g., after missing days)
    public mutating func resetStreak() {
        currentStreak = 0
    }
}

// MARK: - PuzzleAttempt

/// Represents a single attempt at solving a puzzle (for data collection).
///
/// This data structure is designed for ML training, capturing both the
/// puzzle state and the user's actions.
public struct PuzzleAttempt: Codable {
    
    /// Unique identifier for this attempt
    public let id: String
    
    /// The puzzle being attempted
    public let puzzleId: String
    
    /// Timestamp when attempt started
    public let startTime: Date
    
    /// Timestamp when attempt ended
    public var endTime: Date?
    
    /// Sequence of moves made by the user
    public var moveSequence: [Int]
    
    /// Whether the attempt was successful
    public var solved: Bool
    
    /// Time taken to solve (in seconds)
    public var timeToSolve: Double? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    /// User's difficulty level at time of attempt
    public let userDifficulty: PuzzleDifficulty
    
    /// Device information (for context)
    public let deviceInfo: String
    
    // MARK: - Initialization
    
    public init(
        puzzleId: String,
        userDifficulty: PuzzleDifficulty,
        deviceInfo: String = Self.currentDeviceInfo()
    ) {
        self.id = UUID().uuidString
        self.puzzleId = puzzleId
        self.startTime = Date()
        self.endTime = nil
        self.moveSequence = []
        self.solved = false
        self.userDifficulty = userDifficulty
        self.deviceInfo = deviceInfo
    }
    
    /// Gets the current device information in a cross-platform way
    private static func currentDeviceInfo() -> String {
        #if os(iOS) || os(tvOS)
        return UIDevice.current.model
        #elseif os(OSX)
        return "macOS"
        #else
        return "Unknown"
        #endif
    }
    
    /// Records a move made by the user
    public mutating func recordMove(_ cellIndex: Int) {
        moveSequence.append(cellIndex)
    }
    
    /// Completes the attempt
    public mutating func complete(solved: Bool) {
        self.solved = solved
        self.endTime = Date()
    }
}
