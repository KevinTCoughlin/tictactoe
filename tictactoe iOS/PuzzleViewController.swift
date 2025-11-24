//
//  PuzzleViewController.swift
//  tictactoe iOS
//
//  Created by GitHub Copilot on 11/24/25.
//

import UIKit
import SpriteKit

/// View controller for the puzzle mode.
///
/// This controller presents the puzzle scene and manages puzzle-related UI.
final class PuzzleViewController: UIViewController {
    
    // MARK: - Properties
    
    /// The puzzle scene
    private var puzzleScene: PuzzleScene?
    
    /// The SpriteKit view
    private var skView: SKView? {
        view as? SKView
    }
    
    /// Close button to return to main menu
    private lazy var closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark.circle.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        config.baseForegroundColor = .secondaryLabel
        
        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// Stats button to view progress
    private lazy var statsButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chart.bar.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        config.baseForegroundColor = .secondaryLabel
        
        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.showStats()
        })
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        // Create SKView
        let skView = SKView(frame: .zero)
        self.view = skView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPuzzleScene()
        setupUI()
        loadPuzzle()
    }
    
    // MARK: - Setup
    
    private func setupPuzzleScene() {
        guard let skView = skView else { return }
        
        // Create puzzle scene
        let sceneSize = determineSceneSize(for: skView)
        let scene = PuzzleScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        
        // Set callbacks
        scene.onPuzzleCompleted = { [weak self] puzzle, solved, time in
            self?.handlePuzzleCompleted(puzzle: puzzle, solved: solved, time: time)
        }
        
        scene.onNextPuzzle = { [weak self] in
            self?.loadNextPuzzle()
        }
        
        // Present scene
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif
        
        self.puzzleScene = scene
    }
    
    private func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(statsButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            statsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func determineSceneSize(for skView: SKView) -> CGSize {
        if let windowScene = view.window?.windowScene {
            return windowScene.screen.bounds.size
        }
        return skView.bounds.size
    }
    
    // MARK: - Puzzle Management
    
    private func loadPuzzle() {
        let puzzle = PuzzleManager.shared.generatePuzzle()
        puzzleScene?.presentPuzzle(puzzle)
    }
    
    private func loadNextPuzzle() {
        loadPuzzle()
    }
    
    private func handlePuzzleCompleted(puzzle: GamePuzzle, solved: Bool, time: TimeInterval) {
        // Record completion
        Task { @MainActor in
            PuzzleManager.shared.recordPuzzleCompletion(
                puzzle: puzzle,
                solved: solved,
                timeInSeconds: time
            )
            
            // Show brief celebration
            if solved {
                showCompletionMessage(puzzle: puzzle, time: time)
            }
        }
    }
    
    // MARK: - UI Actions
    
    private func showStats() {
        let stats = PuzzleManager.shared.getSummaryStatistics()
        
        let alert = UIAlertController(
            title: "Puzzle Statistics",
            message: """
            Difficulty: \(stats.currentDifficulty.rawValue.capitalized)
            
            Total Solved: \(stats.totalSolved) / \(stats.totalAttempts)
            Success Rate: \(String(format: "%.1f", stats.successRate))%
            
            Current Streak: \(stats.currentStreak) 🔥
            Longest Streak: \(stats.longestStreak)
            
            Total Points: \(stats.totalPoints) ⭐️
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showCompletionMessage(puzzle: GamePuzzle, time: TimeInterval) {
        let points = puzzle.difficulty.points
        
        let alert = UIAlertController(
            title: "Puzzle Complete! ✨",
            message: """
            Time: \(String(format: "%.1f", time))s
            Points: +\(points) ⭐️
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Nice!", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Interface Configuration
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}
