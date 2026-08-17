//
//  AppDelegate.swift
//  tictactoe iOS
//
//  Created by Kevin T. Coughlin on 11/2/25.
//

import UIKit
import OSLog

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "tictactoe", category: "AppDelegate")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize ads (only if Google Mobile Ads SDK is available)
        #if canImport(GoogleMobileAds)
        AdManager.shared.initializeAds()
        #endif
        
        // Authenticate with Game Center
        Task { @MainActor in
            GameKitManager.shared.authenticatePlayer()
        }
        
        // Initialize puzzle system
        Task { @MainActor in
            await initializePuzzleSystem()
        }
        
        return true
    }
    
    /// Initializes the puzzle notification system
    @MainActor
    private func initializePuzzleSystem() async {
        // Register notification actions
        PuzzleNotificationManager.shared.registerNotificationActions()
        
        // Request notification permissions
        let granted = await PuzzleNotificationManager.shared.requestAuthorization()
        
        if granted {
            // Schedule daily puzzle notifications
            PuzzleNotificationManager.shared.scheduleDailyPuzzleNotifications()
        }
        
        logger.info("Puzzle system initialized")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for temporary interruptions or when the app transitions
        // to the background.
        // Pause ongoing tasks, disable timers, and throttle rendering here.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Release shared resources, save user data, invalidate timers, and store
        // enough application state to restore it if the app is terminated.
        // Apps supporting background execution receive this callback instead of
        // applicationWillTerminate when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Undo changes made when entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart paused tasks and refresh the interface if needed.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
