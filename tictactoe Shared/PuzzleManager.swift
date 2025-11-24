//
//  PuzzleManager.swift
//  tictactoe Shared
//
//  Created by GitHub Copilot on 11/24/25.
//

import Foundation
import Combine

/// Central manager for the puzzle system.
///
/// This manager coordinates:
/// - Puzzle generation and selection
/// - User profile and progress tracking
/// - Statistics and analytics
/// - Persistence of user data
/// - Data collection for ML training
@MainActor
final class PuzzleManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = PuzzleManager()
    
    // MARK: - Published Properties
    
    /// User's puzzle profile
    @Published private(set) var userProfile: UserPuzzleProfile
    
    /// Current daily puzzle
    @Published private(set) var dailyPuzzle: GamePuzzle?
    
    /// Whether daily puzzle has been completed today
    @Published private(set) var isDailyPuzzleCompleted: Bool = false
    
    // MARK: - Properties
    
    /// Puzzle generator
    private let generator = PuzzleGenerator()
    
    /// Storage for puzzle attempts (for ML training)
    private var attemptHistory: [PuzzleAttempt] = []
    
    /// Maximum attempts to keep in memory before persisting
    private let maxAttemptsInMemory = 100
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let userProfile = "puzzle_user_profile"
        static let attemptHistory = "puzzle_attempt_history"
        static let lastDailyPuzzleDate = "puzzle_last_daily_date"
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load user profile
        if let data = UserDefaults.standard.data(forKey: Keys.userProfile),
           let profile = try? JSONDecoder().decode(UserPuzzleProfile.self, from: data) {
            self.userProfile = profile
        } else {
            self.userProfile = UserPuzzleProfile()
        }
        
        // Load attempt history
        if let data = UserDefaults.standard.data(forKey: Keys.attemptHistory),
           let attempts = try? JSONDecoder().decode([PuzzleAttempt].self, from: data) {
            self.attemptHistory = attempts
        }
        
        // Check daily puzzle status
        checkDailyPuzzleStatus()
    }
    
    // MARK: - Puzzle Generation
    
    /// Generates a puzzle appropriate for the user's current level.
    func generatePuzzle(type: PuzzleType? = nil) -> GamePuzzle {
        generator.generatePuzzle(for: userProfile, type: type)
    }
    
    /// Gets the daily puzzle for today.
    func getDailyPuzzle() -> GamePuzzle {
        let puzzle = generator.generateDailyPuzzle()
        dailyPuzzle = puzzle
        return puzzle
    }
    
    // MARK: - Progress Tracking
    
    /// Records a puzzle attempt and updates user profile.
    func recordPuzzleCompletion(
        puzzle: GamePuzzle,
        solved: Bool,
        timeInSeconds: TimeInterval
    ) {
        // Update user profile
        userProfile.recordPuzzleAttempt(
            puzzle: puzzle,
            solved: solved,
            timeInSeconds: timeInSeconds
        )
        
        // Check if this was the daily puzzle
        if puzzle.id == dailyPuzzle?.id && solved {
            markDailyPuzzleCompleted()
        }
        
        // Save profile
        saveUserProfile()
    }
    
    /// Records a puzzle attempt for ML training data.
    func recordAttempt(_ attempt: PuzzleAttempt) {
        attemptHistory.append(attempt)
        
        // Persist if buffer is full
        if attemptHistory.count >= maxAttemptsInMemory {
            saveAttemptHistory()
        }
    }
    
    // MARK: - Daily Puzzle Management
    
    private func checkDailyPuzzleStatus() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = UserDefaults.standard.object(forKey: Keys.lastDailyPuzzleDate) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)
            isDailyPuzzleCompleted = calendar.isDate(today, inSameDayAs: lastDay)
        } else {
            isDailyPuzzleCompleted = false
        }
        
        // Update streak if needed
        if !userProfile.isStreakActive && !isDailyPuzzleCompleted {
            userProfile.resetStreak()
            saveUserProfile()
        }
    }
    
    private func markDailyPuzzleCompleted() {
        UserDefaults.standard.set(Date(), forKey: Keys.lastDailyPuzzleDate)
        isDailyPuzzleCompleted = true
    }
    
    // MARK: - Persistence
    
    private func saveUserProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: Keys.userProfile)
        }
    }
    
    private func saveAttemptHistory() {
        if let data = try? JSONEncoder().encode(attemptHistory) {
            UserDefaults.standard.set(data, forKey: Keys.attemptHistory)
        }
    }
    
    // MARK: - Statistics
    
    /// Gets statistics for a specific puzzle.
    func getStatistics(for puzzleId: String) -> PuzzleStatistics? {
        userProfile.puzzleStats[puzzleId]
    }
    
    /// Exports attempt history for ML training.
    ///
    /// This data can be used to train a Core ML model for personalized
    /// puzzle generation. Export periodically to a backend service or
    /// local file for model training.
    func exportTrainingData() -> Data? {
        try? JSONEncoder().encode(attemptHistory)
    }
    
    /// Gets summary statistics for display.
    func getSummaryStatistics() -> PuzzleSummaryStatistics {
        PuzzleSummaryStatistics(
            totalAttempts: userProfile.totalAttempts,
            totalSolved: userProfile.totalSolved,
            successRate: userProfile.successRate,
            currentStreak: userProfile.currentStreak,
            longestStreak: userProfile.longestStreak,
            totalPoints: userProfile.totalPoints,
            currentDifficulty: userProfile.currentDifficulty
        )
    }
    
    // MARK: - Testing & Debug
    
    /// Resets all puzzle progress (for testing).
    func resetProgress() {
        userProfile = UserPuzzleProfile()
        attemptHistory = []
        dailyPuzzle = nil
        isDailyPuzzleCompleted = false
        
        UserDefaults.standard.removeObject(forKey: Keys.userProfile)
        UserDefaults.standard.removeObject(forKey: Keys.attemptHistory)
        UserDefaults.standard.removeObject(forKey: Keys.lastDailyPuzzleDate)
    }
}

// MARK: - PuzzleSummaryStatistics

/// Summary statistics for display in UI.
struct PuzzleSummaryStatistics {
    let totalAttempts: Int
    let totalSolved: Int
    let successRate: Double
    let currentStreak: Int
    let longestStreak: Int
    let totalPoints: Int
    let currentDifficulty: PuzzleDifficulty
}
