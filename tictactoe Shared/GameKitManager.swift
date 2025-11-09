//
//  GameKitManager.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/8/25.
//

import GameKit
import Combine

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

/// Manages Game Center authentication and player data.
///
/// This manager handles authenticating the local player with Game Center,
/// managing the authentication UI, and providing access to player information.
@MainActor
final class GameKitManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance of the GameKit manager.
    static let shared = GameKitManager()
    
    // MARK: - Published Properties
    
    /// Whether the local player is authenticated with Game Center.
    @Published private(set) var isAuthenticated = false
    
    /// The local player, if authenticated.
    @Published private(set) var localPlayer: GKLocalPlayer?
    
    /// Error message, if authentication failed.
    @Published private(set) var errorMessage: String?
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        // Private initializer for singleton
        setupAccessPoint()
    }
    
    // MARK: - Access Point Configuration
    
    /// Configures the Game Center access point widget.
    private func setupAccessPoint() {
        #if os(iOS) || os(tvOS)
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.isActive = false // Will be activated after authentication
        #endif
    }
    
    // MARK: - Authentication
    
    /// Authenticates the local player with Game Center.
    ///
    /// This method should be called when your app launches. It uses the modern
    /// authentication API and automatically presents the authentication UI if needed.
    func authenticatePlayer() {
        let player = GKLocalPlayer.local
        
        // Check if already authenticated
        if player.isAuthenticated {
            print("ℹ️ Game Center: Player already authenticated")
            handleSuccessfulAuthentication(player)
            return
        }
        
        print("🔄 Game Center: Starting authentication flow...")
        
        // Modern authentication API (iOS 14+)
        player.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    print("❌ Game Center: Authentication handler received error")
                    self.handleAuthenticationError(error)
                    return
                }
                
                if let viewController = viewController {
                    print("📱 Game Center: Presenting authentication view controller")
                    self.presentAuthenticationViewController(viewController)
                    return
                }
                
                if player.isAuthenticated {
                    print("✅ Game Center: Authentication successful in handler")
                    self.handleSuccessfulAuthentication(player)
                } else {
                    print("⚠️ Game Center: Authentication not completed")
                    self.handleAuthenticationFailure()
                }
            }
        }
    }
    
    /// Presents the Game Center authentication UI when user explicitly requests it.
    ///
    /// This method is for when the user taps a button to sign in, rather than
    /// automatic authentication on app launch.
    func presentGameCenterLogin() {
        let player = GKLocalPlayer.local
        
        if player.isAuthenticated {
            print("ℹ️ Game Center: Already authenticated, showing dashboard instead")
            showGameCenter()
            return
        }
        
        print("🔄 Game Center: User requested login...")
        
        #if os(iOS) || os(tvOS)
        // Try to trigger authentication by showing access point
        GKAccessPoint.shared.isActive = true
        GKAccessPoint.shared.trigger { }
        
        // Also set the authentication handler in case it wasn't set yet
        authenticatePlayer()
        #else
        // On macOS, just call authenticatePlayer
        authenticatePlayer()
        #endif
    }
    
    // MARK: - Private Helpers
    
    /// Handles successful authentication.
    private func handleSuccessfulAuthentication(_ player: GKLocalPlayer) {
        isAuthenticated = true
        localPlayer = player
        errorMessage = nil
        
        // Show the access point widget on iOS/tvOS
        #if os(iOS) || os(tvOS)
        GKAccessPoint.shared.isActive = true
        #endif
        
        print("✅ Game Center: Authenticated as \(player.displayName)")
        
        // Load additional player data if needed
        loadPlayerData()
    }
    
    /// Handles authentication failure.
    private func handleAuthenticationFailure() {
        isAuthenticated = false
        localPlayer = nil
        errorMessage = "Game Center authentication was cancelled."
        
        #if os(iOS) || os(tvOS)
        GKAccessPoint.shared.isActive = false
        #endif
        
        print("⚠️ Game Center: Authentication cancelled")
    }
    
    /// Handles authentication errors.
    private func handleAuthenticationError(_ error: Error) {
        isAuthenticated = false
        localPlayer = nil
        errorMessage = error.localizedDescription
        
        #if os(iOS) || os(tvOS)
        GKAccessPoint.shared.isActive = false
        #endif
        
        print("❌ Game Center Error: \(error.localizedDescription)")
    }
    
    /// Presents the Game Center authentication view controller.
    #if os(iOS) || os(tvOS)
    private func presentAuthenticationViewController(_ viewController: UIViewController) {
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Game Center: Unable to find root view controller")
            return
        }
        
        // Present the authentication view controller
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        
        topController.present(viewController, animated: true)
    }
    #elseif os(OSX)
    private func presentAuthenticationViewController(_ viewController: NSViewController) {
        // Get the main window
        guard let window = NSApplication.shared.windows.first else {
            print("❌ Game Center: Unable to find main window")
            return
        }
        
        // Present the authentication view controller as a sheet
        window.contentViewController?.presentAsSheet(viewController)
    }
    #endif
    
    /// Loads additional player data after authentication.
    private func loadPlayerData() {
        guard let player = localPlayer else { return }
        
        // You can load additional data here, such as:
        // - Player photo
        // - Friends list
        // - Achievements
        // - Leaderboard scores
        
        loadPlayerPhoto(for: player)
    }
    
    /// Loads the player's Game Center photo.
    private func loadPlayerPhoto(for player: GKLocalPlayer) {
        #if os(iOS) || os(tvOS)
        // Modern async/await API
        Task {
            do {
                _ = try await player.loadPhoto(for: .normal)
                print("✅ Game Center: Player photo loaded")
                // Store or use the image as needed
            } catch {
                print("⚠️ Game Center: Failed to load player photo - \(error.localizedDescription)")
            }
        }
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Presents the Game Center dashboard using the modern access point.
    ///
    /// On iOS 14+, this uses the GKAccessPoint to trigger the dashboard.
    /// The access point widget provides a consistent UI across the system.
    func showGameCenter() {
        guard isAuthenticated else {
            print("⚠️ Game Center: Cannot show dashboard - player not authenticated")
            return
        }
        
        #if os(iOS) || os(tvOS)
        // Use the modern access point to trigger the dashboard
        GKAccessPoint.shared.trigger(handler: { })
        #elseif os(OSX)
        // For macOS, show the dashboard in a traditional way
        showGameCenterLegacy()
        #endif
    }
    
    #if os(OSX)
    /// Shows Game Center dashboard on macOS using traditional approach.
    private func showGameCenterLegacy() {
        if #available(macOS 14.0, *) {
            // Use modern API if available
            GKAccessPoint.shared.trigger(handler: { })
        } else {
            // Fallback for older macOS versions
            guard let window = NSApplication.shared.windows.first else { return }
            
            let gameCenterVC = GKGameCenterViewController(state: .default)
            gameCenterVC.gameCenterDelegate = self
            window.contentViewController?.presentAsSheet(gameCenterVC)
        }
    }
    #endif
    
    /// Shows the Game Center access point widget.
    ///
    /// The access point provides quick access to Game Center features
    /// and displays the player's avatar when authenticated.
    func showAccessPoint() {
        #if os(iOS) || os(tvOS)
        GKAccessPoint.shared.isActive = isAuthenticated
        #endif
    }
    
    /// Hides the Game Center access point widget.
    func hideAccessPoint() {
        #if os(iOS) || os(tvOS)
        GKAccessPoint.shared.isActive = false
        #endif
    }
    
    /// Signs out the local player (for testing purposes).
    func signOut() {
        isAuthenticated = false
        localPlayer = nil
        errorMessage = nil
        
        #if os(iOS) || os(tvOS)
        GKAccessPoint.shared.isActive = false
        #endif
        
        print("🚪 Game Center: Signed out")
    }
    
    /// Prints current Game Center authentication status for debugging.
    func printStatus() {
        let player = GKLocalPlayer.local
        print("📊 Game Center Status:")
        print("  - Is Authenticated: \(player.isAuthenticated)")
        print("  - Player: \(player.isAuthenticated ? player.displayName : "None")")
        print("  - Is Underage: \(player.isUnderage)")
        print("  - Manager State: authenticated=\(isAuthenticated)")
        #if os(iOS) || os(tvOS)
        print("  - Access Point Active: \(GKAccessPoint.shared.isActive)")
        print("  - Access Point Presenting: \(GKAccessPoint.shared.isPresentingGameCenter)")
        #endif
    }
}

// MARK: - GKGameCenterControllerDelegate

#if os(OSX)
extension GameKitManager: GKGameCenterControllerDelegate {
    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        Task { @MainActor in
            gameCenterViewController.dismiss(nil)
        }
    }
}
#endif
