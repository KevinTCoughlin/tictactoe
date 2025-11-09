# Interstitial Ad Implementation Summary

## What Was Added

I've successfully added interstitial ad support to your tic-tac-toe game! Here's what was implemented:

## Files Created

### 1. **AdManager.swift**
A comprehensive singleton manager that handles all interstitial ad functionality:

**Key Features:**
- ✅ Automatic ad loading and caching
- ✅ Game counter that shows ads every 3 games
- ✅ Full logging for debugging with OSLog
- ✅ Implements GADFullScreenContentDelegate for ad lifecycle management
- ✅ Automatic pre-loading of next ad after one is shown
- ✅ Force show option for special events
- ✅ Uses Google test ad unit by default for safe testing

**Main Methods:**
- `initializeAds()` - Call on app launch
- `loadInterstitialAd()` - Loads an ad
- `incrementGameCounter(from:)` - Increments counter and shows ad if threshold reached
- `showInterstitialAd(from:)` - Shows loaded ad
- `forceShowAd(from:)` - Manually trigger ad display
- `resetGameCounter()` - Reset the counter

### 2. **INTERSTITIAL_AD_SETUP.md**
Complete setup guide with:
- AdMob account setup instructions
- Swift Package Manager integration steps
- Info.plist configuration
- Testing procedures
- Production checklist
- Privacy compliance guidelines

## Files Modified

### 1. **AppDelegate.swift**
Added ad initialization on app launch:
```swift
AdManager.shared.initializeAds()
```

### 2. **GameScene.swift**
Integrated ad display on game reset:
- Ads appear after every 3 games completed
- Only on iOS (not macOS)
- Seamless integration with existing game flow

## How It Works

### User Flow
1. Player starts a game
2. Game ends (win or draw)
3. Player taps to reset
4. Game counter increments
5. After 3 games, interstitial ad shows
6. Player closes ad
7. Counter resets, next ad loads automatically
8. Gameplay continues

### Technical Flow
```
App Launch → Initialize AdMob SDK → Pre-load first ad
     ↓
Game Ends → Tap to Reset → Increment Counter
     ↓
Counter ≥ 3? → Yes → Show Ad → Reset Counter → Load Next Ad
     ↓
Counter ≥ 3? → No → Continue Playing
```

## Next Steps

### 1. Add Google Mobile Ads SDK (Required)

**Using Swift Package Manager** (Recommended):
1. In Xcode: **File > Add Package Dependencies...**
2. URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
3. Version: 11.0.0 or later
4. Click **Add Package**

### 2. Configure Info.plist (Required)

Add your AdMob App ID:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

Get your App ID from: [https://admob.google.com](https://admob.google.com)

### 3. Testing (Now)

The current implementation uses Google's **test ad unit ID**, so you can test immediately after adding the SDK:

1. Add the Google Mobile Ads SDK
2. Add GADApplicationIdentifier to Info.plist
3. Build and run
4. Play 3 games
5. Watch for ads!

### 4. Production Setup (Before Release)

1. Create an interstitial ad unit in AdMob console
2. Replace test ad unit ID in `AdManager.swift`:
   ```swift
   private let adUnitID = "YOUR_PRODUCTION_AD_UNIT_ID"
   ```
3. Add SKAdNetwork IDs to Info.plist
4. Test thoroughly
5. Submit to App Store

## Configuration Options

### Adjust Ad Frequency

In `AdManager.swift`, change:
```swift
private let gamesBeforeAd = 3  // Show ad every 3 games
```

**Recommendations:**
- **3-5 games**: Good balance
- **2 games**: More aggressive
- **7-10 games**: More user-friendly

### Manual Ad Triggers

You can trigger ads at other times:

```swift
// In GameViewController or GameScene:
AdManager.shared.forceShowAd(from: viewController)
```

**Good times to show ads:**
- After beating a high score
- When viewing leaderboards
- Before starting a tournament
- After unlocking an achievement

## Customization Examples

### Show Ads Only After Wins
```swift
// In GameScene.swift, modify resetGame():
#if os(iOS)
if let viewController = view?.window?.rootViewController {
    // Only increment if there was a winner (not a draw)
    if board.winner != nil {
        AdManager.shared.incrementGameCounter(from: viewController)
    }
}
#endif
```

### Show Ads Every 5 Games
```swift
// In AdManager.swift:
private let gamesBeforeAd = 5
```

### Add Cooldown Between Ads
```swift
// In AdManager.swift, add property:
private var lastAdTime: Date?
private let minimumTimeBetweenAds: TimeInterval = 180 // 3 minutes

// Modify showInterstitialAd:
func showInterstitialAd(from viewController: UIViewController) {
    // Check cooldown
    if let lastTime = lastAdTime {
        let timeSinceLastAd = Date().timeIntervalSince(lastTime)
        if timeSinceLastAd < minimumTimeBetweenAds {
            logger.info("Ad cooldown active, skipping")
            return
        }
    }
    
    guard let interstitialAd else {
        logger.warning("Attempted to show interstitial ad but none is loaded")
        loadInterstitialAd()
        return
    }
    
    logger.info("Presenting interstitial ad")
    lastAdTime = Date()
    interstitialAd.present(fromRootViewController: viewController)
}
```

## Debugging

### Enable Detailed Logging

The AdManager uses OSLog for logging. To view logs in Console.app:

1. Open **Console.app** on Mac
2. Connect your device or simulator
3. Filter by "tictactoe" or "AdManager"
4. Look for messages about ad loading and presentation

### Check Ad Status

Add this to print ad status:
```swift
// Anywhere in your code:
AdManager.shared.printStatus()  // If you add this method

// Or check in debugger:
po AdManager.shared
```

### Common Log Messages

**Success:**
```
[AdManager] Initializing Google Mobile Ads SDK
[AdManager] Loading interstitial ad
[AdManager] Interstitial ad loaded successfully
[AdManager] Games played since last ad: 3
[AdManager] Presenting interstitial ad
[AdManager] Ad dismissed full screen content
```

**Warnings (Normal):**
```
[AdManager] Attempted to show interstitial ad but none is loaded
[AdManager] Already loading an ad, skipping
```

**Errors (Need Attention):**
```
[AdManager] Failed to load interstitial ad: [error details]
[AdManager] Ad failed to present: [error details]
```

## Privacy Considerations

### App Tracking Transparency (ATT)

For personalized ads on iOS 14.5+, you need to request tracking permission:

```swift
import AppTrackingTransparency

// Add to AppDelegate:
func applicationDidBecomeActive(_ application: UIApplication) {
    if #available(iOS 14.5, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("Tracking authorized")
            case .denied:
                print("Tracking denied")
            case .notDetermined:
                print("Tracking not determined")
            case .restricted:
                print("Tracking restricted")
            @unknown default:
                break
            }
        }
    }
}
```

Add to Info.plist:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use your data to provide personalized ads and improve your experience.</string>
```

## Best Practices

### ✅ Do's
- ✅ Test with test ad unit IDs during development
- ✅ Pre-load ads before showing them
- ✅ Respect user experience (don't show ads too frequently)
- ✅ Handle ad failures gracefully
- ✅ Log errors for debugging
- ✅ Follow AdMob policies

### ❌ Don'ts
- ❌ Don't click your own ads
- ❌ Don't encourage users to click ads
- ❌ Don't show ads too frequently (poor user experience)
- ❌ Don't use production ad IDs during testing
- ❌ Don't ignore ad load failures

## Performance Considerations

### Memory Management
- Ad manager uses weak references to avoid retain cycles
- Ads are deallocated after being shown
- New ads pre-load automatically

### Network Usage
- Ads load in background
- Uses minimal data
- Respects iOS Low Data Mode

### Impact on Gameplay
- Ads don't block game initialization
- Ads only show between games
- No impact on frame rate or responsiveness

## Revenue Optimization Tips

1. **Ad Frequency**: Start with 3 games, adjust based on metrics
2. **User Retention**: Monitor if ads affect retention
3. **Ad Placement**: Between games is non-intrusive
4. **Testing**: A/B test different frequencies
5. **Balance**: Too many ads = users leave, too few = less revenue

## Monitoring & Analytics

### Key Metrics to Track
- **Fill Rate**: % of ad requests that return ads
- **Impressions**: Number of times ads are shown
- **eCPM**: Revenue per thousand impressions
- **Click Rate**: % of ads clicked
- **User Retention**: Are ads affecting retention?

### Where to Find Metrics
- AdMob Console: [https://apps.admob.com](https://apps.admob.com)
- Check daily for performance insights
- Monitor user reviews for ad complaints

## Troubleshooting Guide

### Problem: Ads Not Loading
**Solutions:**
1. Check Info.plist for GADApplicationIdentifier
2. Verify SDK is properly installed
3. Check console for error messages
4. Wait - new ad units take time to fill
5. Try with test ad unit ID first

### Problem: Ads Loading But Not Showing
**Solutions:**
1. Check if ad is nil before presenting
2. Verify viewController is valid
3. Check for modal presentations blocking ads
4. Review console logs for presentation errors

### Problem: "No Fill" Errors
**Solutions:**
1. Normal for new ad units
2. May not have inventory in your region
3. Try test ads to verify implementation works
4. Wait 24-48 hours for inventory

## Additional Resources

- **Setup Guide**: See `INTERSTITIAL_AD_SETUP.md`
- **AdMob Documentation**: [https://developers.google.com/admob/ios](https://developers.google.com/admob/ios)
- **SDK Reference**: [https://developers.google.com/admob/ios/api/reference](https://developers.google.com/admob/ios/api/reference)

## Questions?

For implementation questions, check the logs in AdManager.swift. All major actions are logged for debugging purposes.

Good luck with your monetization! 🎮💰
