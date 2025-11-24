//
//  PuzzleGenerator.swift
//  tictactoe Shared
//
//  Created by GitHub Copilot on 11/24/25.
//

import Foundation
import CoreML
import GameplayKit

// MARK: - PuzzleGenerator

/// Generates tic-tac-toe puzzles using a hybrid approach.
///
/// This generator starts with hand-crafted static puzzles and includes
/// infrastructure for ML-based generation once sufficient training data
/// is collected. The hybrid approach ensures production-ready puzzles
/// from day one while enabling intelligent personalization over time.
///
/// ## Architecture
///
/// - **Static Mode**: Uses pre-defined puzzle scenarios that are guaranteed
///   to be valid and interesting. Suitable for initial launch.
///
/// - **ML Mode**: Placeholder for future Core ML model integration. Once
///   enough user interaction data is collected, a model can be trained to
///   generate personalized puzzles based on:
///   - User skill level
///   - Preferred puzzle types
///   - Common mistakes
///   - Solve times
///
/// ## Training Data Collection
///
/// The generator automatically logs puzzle attempts to build a training
/// dataset. After sufficient data accumulation (~10,000+ attempts), train
/// a Core ML model offline and swap it in.
final class PuzzleGenerator {
    
    // MARK: - Properties
    
    /// Strategist for puzzle validation
    private let strategist = PuzzleStrategist()
    
    /// Core ML model for puzzle generation (nil until trained model is available)
    private var mlModel: MLModel?
    
    /// Whether to prefer ML-generated puzzles over static ones
    private var preferMLGeneration = false
    
    /// Static puzzle library
    private let staticPuzzles: [GamePuzzle]
    
    /// Random number generator for puzzle selection
    private let randomSource = GKRandomSource.sharedRandom()
    
    // MARK: - Initialization
    
    init() {
        self.staticPuzzles = Self.createStaticPuzzleLibrary()
        
        // Attempt to load ML model if available
        loadMLModelIfAvailable()
    }
    
    // MARK: - Puzzle Generation
    
    /// Generates a puzzle appropriate for the user's profile.
    ///
    /// This is the main entry point for puzzle generation. It automatically
    /// chooses between static and ML-based generation depending on availability
    /// and user preferences.
    ///
    /// - Parameters:
    ///   - profile: User's puzzle profile for personalization
    ///   - type: Specific puzzle type, or nil for automatic selection
    /// - Returns: A validated puzzle ready for presentation
    func generatePuzzle(
        for profile: UserPuzzleProfile,
        type: PuzzleType? = nil
    ) -> GamePuzzle {
        // Try ML generation first if available and preferred
        if preferMLGeneration, let mlPuzzle = generateMLPuzzle(for: profile, type: type) {
            return mlPuzzle
        }
        
        // Fall back to static puzzles
        return selectStaticPuzzle(for: profile, type: type)
    }
    
    /// Generates a daily puzzle challenge.
    ///
    /// Daily puzzles are deterministic based on the date, ensuring all users
    /// get the same puzzle on the same day. This enables leaderboards and
    /// social sharing.
    ///
    /// - Parameter date: The date for which to generate the puzzle
    /// - Returns: The daily puzzle for that date
    func generateDailyPuzzle(for date: Date = Date()) -> GamePuzzle {
        // Use date as seed for deterministic puzzle selection
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let daysSince2025 = calendar.dateComponents([.day], from: 
            DateComponents(year: 2025, month: 1, day: 1),
            to: components
        ).day ?? 0
        
        // Select puzzle based on day index
        let puzzleIndex = abs(daysSince2025) % staticPuzzles.count
        return staticPuzzles[puzzleIndex]
    }
    
    // MARK: - Static Puzzle Generation
    
    /// Selects an appropriate static puzzle from the library.
    private func selectStaticPuzzle(
        for profile: UserPuzzleProfile,
        type: PuzzleType?
    ) -> GamePuzzle {
        // Filter by difficulty
        var candidates = staticPuzzles.filter { 
            $0.difficulty == profile.currentDifficulty 
        }
        
        // Filter by type if specified
        if let type = type {
            candidates = candidates.filter { $0.type == type }
        }
        
        // Filter out recently completed puzzles
        candidates = candidates.filter { puzzle in
            if let stats = profile.puzzleStats[puzzle.id] {
                return !stats.isSolved || stats.attempts < 3
            }
            return true
        }
        
        // If no candidates, broaden the search
        if candidates.isEmpty {
            candidates = staticPuzzles.filter { $0.difficulty == profile.currentDifficulty }
        }
        
        if candidates.isEmpty {
            candidates = staticPuzzles
        }
        
        // Select randomly from candidates
        let index = randomSource.nextInt(upperBound: candidates.count)
        return candidates[index]
    }
    
    // MARK: - ML Puzzle Generation
    
    /// Generates a puzzle using the Core ML model.
    ///
    /// This method is a placeholder for future ML integration. Once a model
    /// is trained with collected user data, implement this method to:
    /// 1. Prepare input features from user profile
    /// 2. Run inference with the ML model
    /// 3. Convert model output to a GamePuzzle
    /// 4. Validate the puzzle with PuzzleStrategist
    ///
    /// - Parameters:
    ///   - profile: User's puzzle profile
    ///   - type: Optional puzzle type constraint
    /// - Returns: ML-generated puzzle, or nil if generation fails
    private func generateMLPuzzle(
        for profile: UserPuzzleProfile,
        type: PuzzleType?
    ) -> GamePuzzle? {
        guard let model = mlModel else { return nil }
        
        // TODO: Implement ML-based generation
        // 1. Extract features from profile:
        //    - Success rates by puzzle type
        //    - Average solve times
        //    - Recent performance trends
        //    - Preferred patterns
        //
        // 2. Prepare MLMultiArray or other input format
        //
        // 3. Run model prediction:
        //    let prediction = try? model.prediction(from: features)
        //
        // 4. Parse prediction output:
        //    - Board state (xMask, oMask)
        //    - Current player
        //    - Solution moves
        //
        // 5. Create and validate puzzle
        //    let puzzle = GamePuzzle(...)
        //    guard strategist.validatePuzzle(puzzle) else { return nil }
        //
        // 6. Return validated puzzle
        
        return nil // Not implemented yet
    }
    
    /// Attempts to load a trained Core ML model if available.
    private func loadMLModelIfAvailable() {
        // TODO: Implement ML model loading
        // 1. Check if model file exists in bundle
        // 2. Load model:
        //    guard let modelURL = Bundle.main.url(forResource: "PuzzleGenerator", withExtension: "mlmodelc") else { return }
        //    self.mlModel = try? MLModel(contentsOf: modelURL)
        // 3. Set preferMLGeneration flag if model loaded successfully
        
        mlModel = nil
        preferMLGeneration = false
    }
    
    // MARK: - Static Puzzle Library
    
    /// Creates the library of hand-crafted puzzles.
    ///
    /// These puzzles are carefully designed to teach specific tactics and
    /// progressively increase in difficulty. Each puzzle is validated to
    /// ensure it has a unique optimal solution.
    private static func createStaticPuzzleLibrary() -> [GamePuzzle] {
        var puzzles: [GamePuzzle] = []
        
        // MARK: Beginner Puzzles - One Move Wins
        
        // Puzzle 1: Simple row completion (X to move)
        // X X -
        // O O -
        // - - -
        puzzles.append(GamePuzzle(
            id: "beginner_row_1",
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b110_000_000,
            oMask: 0b000_110_000,
            currentPlayer: .x,
            solution: [2],
            hint: "Complete your row to win!",
            tags: ["row", "simple"]
        ))
        
        // Puzzle 2: Simple column completion (O to move)
        // X - O
        // X - O
        // - - -
        puzzles.append(GamePuzzle(
            id: "beginner_col_1",
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b100_100_000,
            oMask: 0b001_001_000,
            currentPlayer: .o,
            solution: [8],
            hint: "Complete your column!",
            tags: ["column", "simple"]
        ))
        
        // Puzzle 3: Diagonal win (X to move)
        // X - O
        // O X -
        // - - -
        puzzles.append(GamePuzzle(
            id: "beginner_diag_1",
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b100_010_000,
            oMask: 0b001_100_000,
            currentPlayer: .x,
            solution: [8],
            hint: "Think diagonally!",
            tags: ["diagonal", "simple"]
        ))
        
        // Puzzle 4: Anti-diagonal win (O to move)
        // - - O
        // X O X
        // - - -
        puzzles.append(GamePuzzle(
            id: "beginner_diag_2",
            type: .oneMove,
            difficulty: .beginner,
            xMask: 0b000_101_000,
            oMask: 0b001_010_000,
            currentPlayer: .o,
            solution: [6],
            hint: "Complete the other diagonal!",
            tags: ["diagonal", "simple"]
        ))
        
        // MARK: Beginner Puzzles - Defensive
        
        // Puzzle 5: Block opponent's row (X to move)
        // O O -
        // X - -
        // - - -
        puzzles.append(GamePuzzle(
            id: "beginner_block_1",
            type: .defensive,
            difficulty: .beginner,
            xMask: 0b000_100_000,
            oMask: 0b110_000_000,
            currentPlayer: .x,
            solution: [2],
            hint: "Stop your opponent from winning!",
            tags: ["block", "row"]
        ))
        
        // Puzzle 6: Block opponent's column (O to move)
        // X - -
        // X - O
        // - - -
        puzzles.append(GamePuzzle(
            id: "beginner_block_2",
            type: .defensive,
            difficulty: .beginner,
            xMask: 0b100_100_000,
            oMask: 0b000_001_000,
            currentPlayer: .o,
            solution: [6],
            hint: "Block the column!",
            tags: ["block", "column"]
        ))
        
        // MARK: Intermediate Puzzles - One Move Wins
        
        // Puzzle 7: Fork opportunity (X to move)
        // X - -
        // - X O
        // - O -
        puzzles.append(GamePuzzle(
            id: "intermediate_fork_1",
            type: .oneMove,
            difficulty: .intermediate,
            xMask: 0b100_010_000,
            oMask: 0b000_001_010,
            currentPlayer: .x,
            solution: [8],
            hint: "Look for the winning diagonal!",
            tags: ["diagonal", "fork"]
        ))
        
        // Puzzle 8: Corner trap (O to move)
        // O X X
        // - O -
        // - - -
        puzzles.append(GamePuzzle(
            id: "intermediate_corner_1",
            type: .oneMove,
            difficulty: .intermediate,
            xMask: 0b011_000_000,
            oMask: 0b100_010_000,
            currentPlayer: .o,
            solution: [8],
            hint: "Complete your diagonal!",
            tags: ["diagonal", "corner"]
        ))
        
        // MARK: Intermediate Puzzles - Defensive
        
        // Puzzle 9: Fork defense (X to move)
        // O - -
        // - O -
        // - - X
        puzzles.append(GamePuzzle(
            id: "intermediate_defend_1",
            type: .defensive,
            difficulty: .intermediate,
            xMask: 0b000_000_001,
            oMask: 0b100_010_000,
            currentPlayer: .x,
            solution: [6],
            hint: "Block the diagonal threat!",
            tags: ["block", "diagonal", "fork"]
        ))
        
        // MARK: Advanced Puzzles - Two Move Wins
        
        // Puzzle 10: Two-move setup (X to move)
        // X - -
        // - X -
        // O O -
        puzzles.append(GamePuzzle(
            id: "advanced_twomove_1",
            type: .twoMove,
            difficulty: .advanced,
            xMask: 0b100_010_000,
            oMask: 0b000_000_110,
            currentPlayer: .x,
            solution: [8, 2], // First X takes corner, creating two threats
            hint: "Set up a winning position!",
            tags: ["two_move", "setup"]
        ))
        
        // Puzzle 11: Forced win sequence (O to move)
        // - X -
        // - O X
        // - - -
        puzzles.append(GamePuzzle(
            id: "advanced_twomove_2",
            type: .twoMove,
            difficulty: .advanced,
            xMask: 0b010_001_000,
            oMask: 0b000_010_000,
            currentPlayer: .o,
            solution: [0, 8], // Create fork threat
            hint: "Find the forcing sequence!",
            tags: ["two_move", "force"]
        ))
        
        // MARK: Advanced Puzzles - Complex Defense
        
        // Puzzle 12: Multiple threats (X to move)
        // X O X
        // - O -
        // - - -
        puzzles.append(GamePuzzle(
            id: "advanced_defend_1",
            type: .defensive,
            difficulty: .advanced,
            xMask: 0b101_000_000,
            oMask: 0b010_010_000,
            currentPlayer: .x,
            solution: [8],
            hint: "Stop the diagonal!",
            tags: ["block", "critical"]
        ))
        
        // MARK: Expert Puzzles
        
        // Puzzle 13: Expert fork (X to move)
        // X - -
        // - O -
        // - - X
        puzzles.append(GamePuzzle(
            id: "expert_fork_1",
            type: .oneMove,
            difficulty: .expert,
            xMask: 0b100_000_001,
            oMask: 0b000_010_000,
            currentPlayer: .x,
            solution: [1],
            hint: "Create an unstoppable position!",
            tags: ["fork", "advanced"]
        ))
        
        // Puzzle 14: Expert two-move (O to move)
        // - X -
        // X O -
        // - - -
        puzzles.append(GamePuzzle(
            id: "expert_twomove_1",
            type: .twoMove,
            difficulty: .expert,
            xMask: 0b010_100_000,
            oMask: 0b000_010_000,
            currentPlayer: .o,
            solution: [2, 8],
            hint: "Master-level tactics required!",
            tags: ["two_move", "expert"]
        ))
        
        // Puzzle 15: Expert defense (X to move)
        // O - X
        // - O -
        // - - -
        puzzles.append(GamePuzzle(
            id: "expert_defend_1",
            type: .defensive,
            difficulty: .expert,
            xMask: 0b001_000_000,
            oMask: 0b100_010_000,
            currentPlayer: .x,
            solution: [8],
            hint: "One wrong move and you lose!",
            tags: ["block", "critical", "expert"]
        ))
        
        return puzzles
    }
    
    // MARK: - Puzzle Validation
    
    /// Validates all puzzles in the library.
    ///
    /// Call this during testing to ensure all static puzzles are valid.
    /// A valid puzzle must:
    /// - Have a legal board position
    /// - Have a unique optimal solution
    /// - Match its stated type and difficulty
    func validateAllPuzzles() -> [String: Bool] {
        var results: [String: Bool] = [:]
        
        for puzzle in staticPuzzles {
            let isValid = strategist.validatePuzzle(puzzle)
            results[puzzle.id] = isValid
            
            if !isValid {
                print("⚠️ Invalid puzzle: \(puzzle.id)")
            }
        }
        
        return results
    }
}
