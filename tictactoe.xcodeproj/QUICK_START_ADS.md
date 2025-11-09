# Quick Start: Interstitial Ads

## 🚀 Get Started in 3 Steps

### 1️⃣ Add Google Mobile Ads SDK

**In Xcode:**
- File → Add Package Dependencies...
- Paste: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
- Select version 11.0.0+
- Click Add Package

### 2️⃣ Update Info.plist

Add this key with your AdMob App ID:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

**Get your App ID:** [https://admob.google.com](https://admob.google.com)

### 3️⃣ Build and Test!

1. Build and run your app
2. Play 3 games of tic-tac-toe
3. An ad will appear after the 3rd game! 🎉

---

## 📝 What Was Implemented

### ✅ Files Added
- `AdManager.swift` - Complete ad management system
- `INTERSTITIAL_AD_SETUP.md` - Detailed setup guide
- `INTERSTITIAL_AD_IMPLEMENTATION.md` - Implementation details

### ✅ Files Modified
- `AppDelegate.swift` - Initialize ads on launch
- `GameScene.swift` - Show ads after games

### ✅ Features
- Automatic ad loading and caching
- Shows ads every 3 games
- Full error handling and logging
- Test ads by default (safe for development)

---

## 🔧 Common Customizations

### Change Ad Frequency

**In `AdManager.swift`:**
```swift
private let gamesBeforeAd = 3  // Change this number
```

### Show Ad Manually

**Anywhere in your code:**
```swift
AdManager.shared.forceShowAd(from: viewController)
```

### Show Ads Only After Wins

**In `GameScene.swift`, modify `resetGame()`:**
```swift
#if os(iOS)
if let viewController = view?.window?.rootViewController {
    if board.winner != nil {  // Only if someone won
        AdManager.shared.incrementGameCounter(from: viewController)
    }
}
#endif
```

---

## 🐛 Troubleshooting

### Ads Not Showing?

1. ✅ Did you add the SDK?
2. ✅ Did you update Info.plist with GADApplicationIdentifier?
3. ✅ Are you playing at least 3 games?
4. ✅ Check Xcode console for logs from AdManager

### "No Fill" Error?

This is **normal** for:
- New ad units (wait 24-48 hours)
- Certain regions with less inventory
- Test environments

**Solution:** The code handles this gracefully. Try again or wait for inventory.

---

## 📱 For Production Release

Before submitting to App Store:

### 1. Get Your Production Ad Unit

1. Go to [AdMob Console](https://admob.google.com)
2. Create an Interstitial ad unit
3. Copy the ad unit ID

### 2. Update AdManager.swift

Replace test ID with your production ID:

```swift
// Change this line in AdManager.swift:
private let adUnitID = "ca-app-pub-3940256099942544/4411468910"

// To your actual ID:
private let adUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
```

### 3. Add SKAdNetwork IDs

Add to Info.plist (get full list from [Google's documentation](https://developers.google.com/admob/ios/3p-skadnetworks)):

```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Add all required IDs -->
</array>
```

### 4. Optional: Add Tracking Permission

For personalized ads, add to Info.plist:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We show ads to keep the app free. Your data helps us provide relevant ads.</string>
```

And request permission in AppDelegate:

```swift
import AppTrackingTransparency

func applicationDidBecomeActive(_ application: UIApplication) {
    if #available(iOS 14.5, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            // Handle response
        }
    }
}
```

---

## 📊 How to Monitor Performance

1. Go to [AdMob Console](https://apps.admob.com)
2. View your app's dashboard
3. Monitor:
   - **Impressions**: How many ads shown
   - **Fill Rate**: % of requests that returned ads
   - **eCPM**: Earnings per thousand impressions
   - **Revenue**: Your earnings!

---

## 💡 Best Practices

### ✅ Do This
- Use test ads during development
- Show ads between natural breaks (like after games)
- Monitor user retention
- Test on multiple devices
- Follow AdMob policies

### ❌ Avoid This
- Don't click your own ads (policy violation!)
- Don't show ads too frequently (annoying)
- Don't use production IDs during testing
- Don't encourage users to click ads

---

## 📚 Need More Help?

- **Detailed Setup**: See `INTERSTITIAL_AD_SETUP.md`
- **Implementation Details**: See `INTERSTITIAL_AD_IMPLEMENTATION.md`
- **AdMob Docs**: [https://developers.google.com/admob/ios](https://developers.google.com/admob/ios)
- **Support**: [https://support.google.com/admob](https://support.google.com/admob)

---

## 🎮 Current Behavior

**Your game now:**
1. Tracks games played
2. Shows an ad after every 3 games
3. Pre-loads next ad automatically
4. Logs everything for debugging
5. Handles errors gracefully

**User Experience:**
```
Game 1 → Reset → Continue Playing
Game 2 → Reset → Continue Playing  
Game 3 → Reset → 🎬 AD SHOWS 🎬 → Continue Playing
Game 4 → Reset → Continue Playing
...
```

---

## 🎯 Summary

You're all set! The ad system is fully implemented and ready to test. Just:

1. Add the Google Mobile Ads SDK
2. Update Info.plist with your App ID
3. Build and play!

The current implementation uses **test ads**, so you can start testing immediately without risk of policy violations.

When you're ready for production, simply replace the ad unit ID in `AdManager.swift` with your real ad unit from AdMob.

**Happy monetizing! 💰**
