//
//  GameViewController.swift
//  tictactoe iOS
//
//  Created by Kevin T. Coughlin on 11/2/25.
//

import UIKit
import SpriteKit
import GameKit
import OSLog

/// View controller responsible for presenting and managing the tic-tac-toe game scene.
///
/// This controller sets up a SpriteKit view and configures the game scene with appropriate
/// scaling and presentation options for optimal gameplay experience.
final class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "tictactoe", category: "GameViewController")
    
    /// The SpriteKit view used to display the game scene.
    private var skView: SKView? {
        view as? SKView
    }
    
    /// Button to access Game Center features.
    private lazy var gameCenterButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemGreen.withAlphaComponent(0.9)
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "gamecontroller.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.handleGameCenterButtonTap()
        })
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0 // Start hidden, will fade in after authentication check
        
        return button
    }()
    
    /// Button to access puzzle mode.
    private lazy var puzzleButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemBlue.withAlphaComponent(0.9)
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "puzzlepiece.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.handlePuzzleButtonTap()
        })
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGameView()
        configureGameCenter()
        setupGameCenterButton()
        setupPuzzleButton()
        observeGameCenterStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure Game Center access point is visible after view appears
        if GKLocalPlayer.local.isAuthenticated {
            GKAccessPoint.shared.isActive = true
        }
    }
    
    // MARK: - Configuration
    
    /// Configures Game Center access point for in-game display.
    private func configureGameCenter() {
        // Configure the access point appearance
        GKAccessPoint.shared.location = .topLeading
        
        // The access point will be activated by GameKitManager when authenticated
        logger.info("Game Center access point configured")
    }
    
    /// Sets up the Game Center button in the view hierarchy.
    private func setupGameCenterButton() {
        view.addSubview(gameCenterButton)
        
        NSLayoutConstraint.activate([
            gameCenterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            gameCenterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        // Show button after a delay to check authentication status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateGameCenterButton()
        }
    }
    
    /// Sets up the Puzzle button in the view hierarchy.
    private func setupPuzzleButton() {
        view.addSubview(puzzleButton)
        
        NSLayoutConstraint.activate([
            puzzleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            puzzleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// Observes Game Center authentication status changes.
    private func observeGameCenterStatus() {
        // Observe authentication state changes
        NotificationCenter.default.addObserver(
            forName: .GKPlayerAuthenticationDidChangeNotificationName,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateGameCenterButton()
        }
    }
    
    /// Updates the Game Center button appearance based on authentication status.
    private func updateGameCenterButton() {
        let isAuthenticated = GKLocalPlayer.local.isAuthenticated
        
        var config = gameCenterButton.configuration
        if isAuthenticated {
            config?.baseBackgroundColor = .systemGreen.withAlphaComponent(0.9)
            config?.image = UIImage(systemName: "gamecontroller.fill")
        } else {
            config?.baseBackgroundColor = .systemGray.withAlphaComponent(0.9)
            config?.image = UIImage(systemName: "gamecontroller")
        }
        gameCenterButton.configuration = config
        
        // Fade in the button
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.gameCenterButton.alpha = 1.0
        }
        
        logger.info("Game Center button updated - authenticated: \(isAuthenticated)")
    }
    
    /// Handles Game Center button tap.
    private func handleGameCenterButtonTap() {
        logger.info("Game Center button tapped")
        
        // Print diagnostic info
        GameKitManager.shared.printStatus()
        
        if GKLocalPlayer.local.isAuthenticated {
            logger.info("Opening Game Center dashboard")
            GameKitManager.shared.showGameCenter()
        } else {
            logger.info("User tapped to sign in to Game Center")
            GameKitManager.shared.presentGameCenterLogin()
        }
    }
    
    /// Handles Puzzle button tap.
    private func handlePuzzleButtonTap() {
        logger.info("Puzzle button tapped")
        
        // Create and present puzzle view controller
        let puzzleVC = PuzzleViewController()
        puzzleVC.modalPresentationStyle = .fullScreen
        present(puzzleVC, animated: true)
    }
    
    /// Configures the SpriteKit view and presents the game scene.
    private func configureGameView() {
        guard let skView else {
            logger.error("View is not an SKView. Cannot present game scene.")
            assertionFailure("GameViewController's view must be an SKView")
            return
        }
        
        let scene = createGameScene(for: skView)
        presentScene(scene, in: skView)
        configureDebugOptions(for: skView)
    }
    
    /// Creates and configures the game scene with appropriate size and scale mode.
    ///
    /// - Parameter skView: The SpriteKit view that will present the scene.
    /// - Returns: A configured `GameScene` instance ready for presentation.
    private func createGameScene(for skView: SKView) -> GameScene {
        // Try loading from .sks file first for designer-configured scenes
        if let sksScene = SKScene(fileNamed: "GameScene") as? GameScene {
            logger.info("Loaded GameScene from .sks file")
            return sksScene
        }
        
        // Determine optimal scene size from view hierarchy
        let sceneSize = determineSceneSize(for: skView)
        logger.info("Creating GameScene with size: \(sceneSize.width) x \(sceneSize.height)")
        
        return GameScene(size: sceneSize)
    }
    
    /// Determines the optimal scene size based on the view hierarchy and screen dimensions.
    ///
    /// - Parameter skView: The SpriteKit view to size for.
    /// - Returns: The calculated scene size.
    private func determineSceneSize(for skView: SKView) -> CGSize {
        // Prefer window scene dimensions for multi-window support
        if let windowScene = view.window?.windowScene {
            return windowScene.screen.bounds.size
        }
        
        // Fall back to view bounds if window scene unavailable
        return skView.bounds.size
    }
    
    /// Presents the scene in the SpriteKit view with appropriate configuration.
    ///
    /// - Parameters:
    ///   - scene: The scene to present.
    ///   - skView: The view in which to present the scene.
    private func presentScene(_ scene: GameScene, in skView: SKView) {
        // Configure scale mode for consistent appearance across device sizes
        scene.scaleMode = .aspectFill
        
        // Present with smooth transition
        skView.presentScene(scene)
        
        // Optimize rendering
        skView.ignoresSiblingOrder = true
    }
    
    /// Configures debug display options for development builds.
    ///
    /// - Parameter skView: The view to configure.
    private func configureDebugOptions(for skView: SKView) {
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.showsPhysics = false // Enable if physics debugging needed
        logger.debug("Debug options enabled")
        #endif
    }
    
    // MARK: - Interface Configuration
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Phone: portrait and landscape (but not upside down for safety/ergonomics)
        // Tablet: all orientations
        UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }
    
    override var prefersStatusBarHidden: Bool {
        // Hide status bar for immersive game experience
        true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        // Auto-hide home indicator for more immersive gameplay
        true
    }
}

