//
//  AdManager.swift
//  tictactoe iOS
//
//  Created by Kevin T. Coughlin on 11/9/25.
//

#if canImport(GoogleMobileAds)

import UIKit
import GoogleMobileAds
import OSLog

/// Manager responsible for loading and presenting interstitial ads throughout the app.
///
/// This singleton class handles the lifecycle of interstitial ads, including loading,
/// presenting, and tracking display frequency to ensure a good user experience.
final class AdManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = AdManager()
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "tictactoe", category: "AdManager")
    
    /// The currently loaded interstitial ad, if any.
    private var interstitialAd: GADInterstitialAd?
    
    /// Indicates whether an ad is currently being loaded.
    private var isLoadingAd = false
    
    /// Counter for games played since last ad shown.
    private var gamesPlayedSinceLastAd = 0
    
    /// Number of games to play before showing an ad.
    private let gamesBeforeAd = 3
    
    /// Test ad unit ID - Replace with your production ad unit ID before release.
    /// Get your ad unit ID from AdMob console: https://apps.admob.com/
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910" // Google test ad unit
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Initializes the Google Mobile Ads SDK.
    /// Call this from AppDelegate on app launch.
    func initializeAds() {
        logger.info("Initializing Google Mobile Ads SDK")
        
        GADMobileAds.sharedInstance().start { [weak self] status in
            self?.logger.info("Google Mobile Ads SDK initialized with status: \(status.description)")
            
            // Pre-load the first ad
            self?.loadInterstitialAd()
        }
    }
    
    /// Loads an interstitial ad if one is not already loaded or loading.
    func loadInterstitialAd() {
        guard !isLoadingAd else {
            logger.info("Already loading an ad, skipping")
            return
        }
        
        guard interstitialAd == nil else {
            logger.info("Ad already loaded, skipping")
            return
        }
        
        isLoadingAd = true
        logger.info("Loading interstitial ad")
        
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }
            
            self.isLoadingAd = false
            
            if let error {
                self.logger.error("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            
            guard let ad else {
                self.logger.error("Interstitial ad loaded but ad object is nil")
                return
            }
            
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.logger.info("Interstitial ad loaded successfully")
        }
    }
    
    /// Increments the game counter and shows an ad if the threshold is reached.
    ///
    /// - Parameter viewController: The view controller to present the ad from.
    func incrementGameCounter(from viewController: UIViewController) {
        gamesPlayedSinceLastAd += 1
        logger.info("Games played since last ad: \(self.gamesPlayedSinceLastAd)")
        
        if gamesPlayedSinceLastAd >= gamesBeforeAd {
            showInterstitialAd(from: viewController)
        }
    }
    
    /// Shows an interstitial ad if one is loaded.
    ///
    /// - Parameter viewController: The view controller to present the ad from.
    func showInterstitialAd(from viewController: UIViewController) {
        guard let interstitialAd else {
            logger.warning("Attempted to show interstitial ad but none is loaded")
            // Try to load for next time
            loadInterstitialAd()
            return
        }
        
        logger.info("Presenting interstitial ad")
        interstitialAd.present(fromRootViewController: viewController)
    }
    
    /// Manually shows an ad regardless of the counter.
    /// Useful for specific events like completing a level or achievement.
    ///
    /// - Parameter viewController: The view controller to present the ad from.
    func forceShowAd(from viewController: UIViewController) {
        if interstitialAd != nil {
            showInterstitialAd(from: viewController)
        } else {
            logger.info("Force show requested but no ad loaded, loading one now")
            loadInterstitialAd()
        }
    }
    
    /// Resets the game counter. Call this if you want to change when ads appear.
    func resetGameCounter() {
        gamesPlayedSinceLastAd = 0
        logger.info("Game counter reset")
    }
}

// MARK: - GADFullScreenContentDelegate

extension AdManager: GADFullScreenContentDelegate {
    
    /// Called when the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        logger.error("Ad failed to present: \(error.localizedDescription)")
        interstitialAd = nil
        // Load a new ad
        loadInterstitialAd()
    }
    
    /// Called when the ad presented full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        logger.info("Ad will present full screen content")
    }
    
    /// Called when the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        logger.info("Ad dismissed full screen content")
        
        // Reset counter
        gamesPlayedSinceLastAd = 0
        
        // Clear the ad reference
        interstitialAd = nil
        
        // Pre-load next ad
        loadInterstitialAd()
    }
    
    /// Called when the ad impression was recorded.
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        logger.info("Ad impression recorded")
    }
    
    /// Called when a click was recorded for the ad.
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        logger.info("Ad click recorded")
    }
}

#endif // canImport(GoogleMobileAds)
