# Interstitial Ad Setup Guide

This guide will help you integrate Google Mobile Ads (AdMob) interstitial ads into your tic-tac-toe game.

## Prerequisites

1. **Google AdMob Account**: Create an account at [https://admob.google.com](https://admob.google.com)
2. **Register Your App**: Add your app in the AdMob console
3. **Create Ad Units**: Create an interstitial ad unit for your app

## Step 1: Add Google Mobile Ads SDK

### Option A: Swift Package Manager (Recommended)

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
3. Select version `11.0.0` or later
4. Click **Add Package**

### Option B: CocoaPods

Add to your `Podfile`:

```ruby
pod 'Google-Mobile-Ads-SDK'
```

Then run:
```bash
pod install
```

## Step 2: Update Info.plist

Add the following keys to your `Info.plist`:

1. **Google AdMob App ID** (Required):

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

Replace `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` with your actual AdMob App ID from the AdMob console.

2. **App Transport Security** (if needed for testing):

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
```

**Note:** For production, you should remove or restrict ATS settings for better security.

3. **SKAdNetwork Identifiers** (Required for attribution):

Google provides an updated list of SKAdNetwork IDs. Add them to your Info.plist. You can find the latest list at:
[https://developers.google.com/admob/ios/3p-skadnetworks](https://developers.google.com/admob/ios/3p-skadnetworks)

Example:
```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4fzdc2evr5.skadnetwork</string>
    </dict>
    <!-- Add all SKAdNetwork IDs from Google's list -->
</array>
```

## Step 3: Update AdManager with Your Ad Unit ID

In `AdManager.swift`, replace the test ad unit ID with your production ad unit ID:

```swift
// Replace this test ID:
private let adUnitID = "ca-app-pub-3940256099942544/4411468910"

// With your actual ad unit ID:
private let adUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
```

**Important:** Keep the test ID during development and testing. Only use your production ID for release builds.

## Step 4: Testing

### Using Test Ads

The current implementation uses Google's test ad unit ID by default. This allows you to test ad functionality without risk of policy violations.

**Test Ad Unit IDs:**
- Interstitial: `ca-app-pub-3940256099942544/4411468910`

### Test Devices

For testing with real ad unit IDs, register your test device:

```swift
// In AdManager.swift, add this to initializeAds():
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
    "YOUR_DEVICE_IDENTIFIER_HERE"
]
```

You can find your device identifier in the Xcode console when you run the app. Look for a log message like:

```
<Google> To get test ads on this device, set:
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = @[ @"33BE2250B43518CCDA68DC28AE092A36" ];
```

## Step 5: Verify Implementation

1. **Build and run** your app
2. **Play 3 games** of tic-tac-toe
3. After the 3rd game completes, an interstitial ad should appear
4. Check Xcode console for log messages from AdManager

Expected logs:
```
Initializing Google Mobile Ads SDK
Loading interstitial ad
Interstitial ad loaded successfully
Games played since last ad: 1
Games played since last ad: 2
Games played since last ad: 3
Presenting interstitial ad
```

## Step 6: Customize Ad Frequency

You can adjust when ads appear by modifying `AdManager.swift`:

```swift
/// Number of games to play before showing an ad.
private let gamesBeforeAd = 3  // Change this number
```

Recommended values:
- **3-5 games**: Good balance for free games
- **2 games**: More aggressive monetization
- **7-10 games**: More user-friendly, less revenue

## Advanced Usage

### Manual Ad Display

You can manually trigger an ad at any time:

```swift
// Force show an ad (e.g., when completing an achievement)
AdManager.shared.forceShowAd(from: viewController)
```

### Pre-loading Ads

The AdManager automatically pre-loads ads after they're shown. You can also manually trigger preloading:

```swift
AdManager.shared.loadInterstitialAd()
```

## Troubleshooting

### Ads Not Showing

1. **Check AdMob Account**: Ensure your app is approved and ad units are active
2. **Wait for Inventory**: New ad units may take hours to fill with ads
3. **Verify Info.plist**: Make sure your GADApplicationIdentifier is correct
4. **Check Console Logs**: Look for error messages from AdManager
5. **Test Device**: Make sure you're using test ads during development

### Common Issues

**"Request Error: No fill"**
- This is normal during testing
- New ad units need time to build ad inventory
- May occur if there are no ads available for your region

**"Invalid GADApplicationIdentifier"**
- Check your Info.plist for typos
- Verify the App ID matches your AdMob console

**Ads Not Loading Fast Enough**
- Consider pre-loading ads earlier in your app lifecycle
- Adjust the `gamesBeforeAd` threshold to give more time

## Production Checklist

Before releasing your app:

- [ ] Replace test ad unit ID with production ad unit ID
- [ ] Remove test device identifiers
- [ ] Add your actual GADApplicationIdentifier to Info.plist
- [ ] Add all required SKAdNetwork IDs
- [ ] Test on multiple devices and iOS versions
- [ ] Verify ads don't show too frequently (App Store policy)
- [ ] Ensure ads don't interfere with gameplay
- [ ] Review AdMob policies: [https://support.google.com/admob/answer/6128543](https://support.google.com/admob/answer/6128543)

## Privacy and Compliance

### App Tracking Transparency (ATT)

For iOS 14.5+, if you want personalized ads, you need to request tracking permission:

```swift
import AppTrackingTransparency
import AdSupport

// In AppDelegate or your initialization code:
if #available(iOS 14.5, *) {
    ATTrackingManager.requestTrackingAuthorization { status in
        // Handle the response
    }
}
```

Add to Info.plist:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>This app uses advertising to provide a free experience. Your data will be used to provide you with personalized ads.</string>
```

### Privacy Manifest

For iOS 17+, you may need to add a privacy manifest file declaring your app's data usage. Consult Apple's documentation and Google's AdMob guidelines for the latest requirements.

## Resources

- [AdMob iOS Documentation](https://developers.google.com/admob/ios/quick-start)
- [Google Mobile Ads SDK Documentation](https://developers.google.com/admob/ios/interstitial)
- [AdMob Policy Guidelines](https://support.google.com/admob/answer/6128543)
- [iOS Privacy Guidelines](https://developer.apple.com/app-store/user-privacy-and-data-use/)

## Support

For issues specific to:
- **AdMob/Google Ads**: [AdMob Support](https://support.google.com/admob)
- **Implementation**: Check AdManager.swift logs in Xcode console
- **App Store**: Review [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
