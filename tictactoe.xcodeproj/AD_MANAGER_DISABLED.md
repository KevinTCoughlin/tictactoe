# Ad Manager - Currently Disabled

## ⚠️ Important Notice

The `AdManager.swift` file has been **temporarily disabled** to allow your project to build without errors.

## Why?

The AdManager requires the **Google Mobile Ads SDK**, which hasn't been added to your project yet. Until you add the SDK, the file would cause compilation errors.

## What's Been Done

1. ✅ **AdManager calls commented out** in:
   - `AppDelegate.swift` - Ad initialization
   - `GameScene.swift` - Ad display triggers

2. ✅ **TODO comments added** to remind you where to uncomment

3. ✅ **AdManager.swift preserved** - All code is ready to use

## How to Enable Ads

Follow these steps to enable the ad system:

### Step 1: Add Google Mobile Ads SDK

**Using Swift Package Manager (Recommended):**

1. Open Xcode
2. Go to **File > Add Package Dependencies...**
3. Paste this URL: 
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
4. Select version **11.0.0** or later
5. Click **Add Package**
6. Wait for the package to download

### Step 2: Update Info.plist

Add your AdMob App ID to `Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

Get your App ID from: https://admob.google.com

### Step 3: Uncomment Ad Code

**In `AppDelegate.swift`:**

Find this line:
```swift
// TODO: Uncomment after adding Google Mobile Ads SDK
// AdManager.shared.initializeAds()
```

Change it to:
```swift
AdManager.shared.initializeAds()
```

**In `GameScene.swift`:**

Find this block:
```swift
// TODO: Uncomment after adding Google Mobile Ads SDK
/*
if let viewController = view?.window?.rootViewController {
    AdManager.shared.incrementGameCounter(from: viewController)
}
*/
```

Change it to:
```swift
if let viewController = view?.window?.rootViewController {
    AdManager.shared.incrementGameCounter(from: viewController)
}
```

### Step 4: Ensure AdManager.swift is in Target

1. In Xcode, select `AdManager.swift` in the Project Navigator
2. Open the **File Inspector** (right panel)
3. Under **Target Membership**, ensure your iOS target is **checked**

### Step 5: Build and Test

1. Build your project (⌘B)
2. Run on simulator or device
3. Play 3 games
4. Watch for an ad to appear!

## Current Status

```
❌ Google Mobile Ads SDK - NOT ADDED
❌ Info.plist - NOT CONFIGURED  
❌ Ad Initialization - COMMENTED OUT
❌ Ad Triggers - COMMENTED OUT
✅ AdManager.swift - READY TO USE
✅ Documentation - COMPLETE
```

## Quick Reference

### Files with TODO Comments

1. **AppDelegate.swift** (line ~17)
   ```swift
   // TODO: Uncomment after adding Google Mobile Ads SDK
   ```

2. **GameScene.swift** (line ~376)
   ```swift
   // TODO: Uncomment after adding Google Mobile Ads SDK
   ```

### Search for TODOs

In Xcode, press **⌘⇧F** and search for:
```
TODO: Uncomment after adding Google Mobile Ads SDK
```

## Documentation

For complete setup instructions, see:

- 📝 **QUICK_START_ADS.md** - 3-step quick setup
- 📚 **INTERSTITIAL_AD_SETUP.md** - Detailed guide
- 📖 **INTERSTITIAL_AD_IMPLEMENTATION.md** - Technical details
- ☑️ **AD_IMPLEMENTATION_CHECKLIST.md** - Step-by-step checklist

## Testing the Changes

Your project should now **build without errors**. Once you're ready to add ads:

1. Follow the steps above
2. Add the SDK
3. Uncomment the code
4. Build and test!

## Questions?

- ❓ **Can't find AdManager.swift?** - It's in your project root
- ❓ **Build still failing?** - Make sure you saved all files
- ❓ **Want to remove ads completely?** - Delete AdManager.swift and the TODO comments

## Summary

✅ Your project now builds successfully  
✅ Ad functionality is preserved for later  
✅ Clear TODOs mark where to uncomment  
✅ Complete documentation available  
✅ Easy to enable when ready  

**Happy coding!** 🚀
