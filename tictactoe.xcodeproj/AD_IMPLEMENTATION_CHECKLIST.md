# Interstitial Ad Implementation Checklist

Use this checklist to track your progress implementing interstitial ads.

## ✅ Development Phase

### Initial Setup
- [ ] **Add Google Mobile Ads SDK**
  - [ ] Open Xcode
  - [ ] File → Add Package Dependencies...
  - [ ] Paste URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
  - [ ] Select version 11.0.0 or later
  - [ ] Click Add Package
  - [ ] Wait for package to download

### Configure Info.plist
- [ ] **Open Info.plist**
- [ ] **Add GADApplicationIdentifier**
  - [ ] Right-click → Add Row
  - [ ] Key: `GADApplicationIdentifier`
  - [ ] Type: String
  - [ ] Value: Your App ID from AdMob
  - [ ] Format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`

### Get Your AdMob App ID
- [ ] **Go to AdMob Console**: https://admob.google.com
- [ ] **Sign in** with Google account
- [ ] **Create an app** (if not already created)
  - [ ] Click "Apps" in sidebar
  - [ ] Click "Add App"
  - [ ] Select iOS platform
  - [ ] Enter app name
  - [ ] Click "Add"
- [ ] **Copy your App ID** from the app settings page
- [ ] **Paste into Info.plist** GADApplicationIdentifier key

### First Build
- [ ] **Build the project** (⌘B)
- [ ] **Fix any build errors**
- [ ] **Run on simulator or device** (⌘R)
- [ ] **Check console for logs**:
  - [ ] Look for: `[AdManager] Initializing Google Mobile Ads SDK`
  - [ ] Look for: `[AdManager] Loading interstitial ad`
  - [ ] Look for: `[AdManager] Interstitial ad loaded successfully`

### Test Ad Display
- [ ] **Play first game**
  - [ ] Make moves until game ends
  - [ ] Tap screen to reset
  - [ ] Console should show: `Games played since last ad: 1`
- [ ] **Play second game**
  - [ ] Make moves until game ends
  - [ ] Tap screen to reset
  - [ ] Console should show: `Games played since last ad: 2`
- [ ] **Play third game**
  - [ ] Make moves until game ends
  - [ ] Tap screen to reset
  - [ ] Console should show: `Games played since last ad: 3`
  - [ ] **🎉 AD SHOULD APPEAR!**

### Verify Ad Lifecycle
- [ ] **When ad appears**:
  - [ ] Ad displays full screen
  - [ ] Close button appears after a few seconds
  - [ ] No crashes or errors
- [ ] **Close the ad**:
  - [ ] Tap close button (X)
  - [ ] Ad dismisses
  - [ ] Returns to game
  - [ ] Console shows: `Ad dismissed full screen content`
  - [ ] Console shows: `Game counter reset`
- [ ] **Play another game**:
  - [ ] Counter resets to 1
  - [ ] Next ad pre-loads in background

### Test Multiple Devices
- [ ] **iPhone simulator**
- [ ] **iPad simulator**
- [ ] **Physical device** (if available)
- [ ] **Different iOS versions** (if possible)

### Document Current State
- [ ] **Screenshot test ad working**
- [ ] **Note any issues or errors**
- [ ] **Verify console logs look correct**

---

## 🚀 Pre-Production Phase

### Create Production Ad Units
- [ ] **Go to AdMob Console**: https://admob.google.com
- [ ] **Navigate to your app**
- [ ] **Click "Ad units" tab**
- [ ] **Create Interstitial Ad Unit**:
  - [ ] Click "Add Ad Unit"
  - [ ] Select "Interstitial"
  - [ ] Enter name (e.g., "Tic Tac Toe Interstitial")
  - [ ] Configure settings
  - [ ] Click "Create Ad Unit"
- [ ] **Copy the Ad Unit ID**
  - [ ] Format: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`
  - [ ] Save this for later

### Update AdManager.swift
- [ ] **Open AdManager.swift**
- [ ] **Find line**: `private let adUnitID = "ca-app-pub-3940256099942544/4411468910"`
- [ ] **Replace with your production ID**
- [ ] **Keep test ID in a comment** for future reference
- [ ] **Build to verify** no typos

### Add SKAdNetwork IDs
- [ ] **Get SKAdNetwork list**: https://developers.google.com/admob/ios/3p-skadnetworks
- [ ] **Copy the XML**
- [ ] **Open Info.plist**
- [ ] **Add SKAdNetworkItems array**
- [ ] **Paste all SKAdNetwork IDs**
- [ ] **Verify XML is valid** (no errors in Xcode)

### Privacy Configuration
- [ ] **Add App Tracking Transparency** (optional but recommended)
  - [ ] Open Info.plist
  - [ ] Add key: `NSUserTrackingUsageDescription`
  - [ ] Type: String
  - [ ] Value: Your privacy message
  - [ ] Example: "We show ads to keep the app free. Your data helps us provide relevant ads."
  
- [ ] **Update AppDelegate** (if using ATT)
  - [ ] Import `AppTrackingTransparency`
  - [ ] Add tracking request code
  - [ ] Test on iOS 14.5+ device

### App Store Preparation
- [ ] **Verify ad frequency** isn't annoying
  - [ ] Get feedback from beta testers
  - [ ] Adjust `gamesBeforeAd` if needed
- [ ] **Test user experience**
  - [ ] Ads don't interrupt gameplay
  - [ ] Ads show at natural breaks
  - [ ] Close button is accessible
- [ ] **Check compliance**
  - [ ] No ads to children under 13 (if applicable)
  - [ ] Privacy policy mentions ads
  - [ ] App Store description mentions ads

---

## 📱 Production Testing

### Test with Production Ads
- [ ] **Use test device registration**
  - [ ] Add your device ID to test devices
  - [ ] See AdMob console for device registration
- [ ] **Build with production ad unit ID**
- [ ] **Run on device**
- [ ] **Verify ads appear**
  - [ ] May take 1-2 hours for first fill
  - [ ] "No fill" errors are normal initially

### Load Testing
- [ ] **Test rapid gameplay**
  - [ ] Play 10+ games quickly
  - [ ] Verify ads load consistently
  - [ ] No crashes or memory issues
- [ ] **Test app backgrounding**
  - [ ] Play game
  - [ ] Background app
  - [ ] Return to app
  - [ ] Verify ads still work
- [ ] **Test network conditions**
  - [ ] WiFi
  - [ ] Cellular data
  - [ ] Low signal (if possible)

### Error Scenarios
- [ ] **Test with no internet**
  - [ ] Turn off WiFi and cellular
  - [ ] Play games
  - [ ] Verify graceful handling
  - [ ] No crashes
- [ ] **Test rapid resets**
  - [ ] Reset game immediately after start
  - [ ] Verify no issues
- [ ] **Test orientation changes** (if applicable)
  - [ ] Rotate device during gameplay
  - [ ] Rotate during ad display

---

## 🎯 App Store Submission

### Code Review
- [ ] **Remove debug code**
- [ ] **Remove test device IDs**
- [ ] **Verify production ad unit ID** is active
- [ ] **Remove any console.log or print statements** (optional)
- [ ] **Verify Info.plist** is complete

### Documentation
- [ ] **Update README** with ad information
- [ ] **Document privacy policy**
  - [ ] Mention use of ads
  - [ ] Mention data collection by ad providers
  - [ ] Link to AdMob privacy policy
- [ ] **Update App Store description**
  - [ ] Mention app is ad-supported
  - [ ] Consider: "Free with ads" or "Ad-supported"

### App Store Connect
- [ ] **Update App Privacy section**
  - [ ] Declare data collection practices
  - [ ] Add advertising identifier usage
  - [ ] Link to privacy policy
- [ ] **Add app preview/screenshots**
  - [ ] Ensure screenshots don't show ads
  - [ ] Highlight game features
- [ ] **Version release notes**
  - [ ] Mention ad support (optional)

### Final Checks
- [ ] **Archive build** (Product → Archive)
- [ ] **Validate archive**
  - [ ] Click "Validate App"
  - [ ] Fix any validation errors
- [ ] **Test archived build**
  - [ ] Export to device via ad hoc
  - [ ] Verify ads still work
- [ ] **Submit to App Store**
  - [ ] Click "Distribute App"
  - [ ] Follow submission process

---

## 📊 Post-Launch Monitoring

### Week 1
- [ ] **Monitor AdMob dashboard daily**
  - [ ] Check impressions
  - [ ] Check fill rate
  - [ ] Check eCPM
- [ ] **Watch for errors**
  - [ ] Check crash reports
  - [ ] Monitor user reviews
  - [ ] Look for ad-related complaints
- [ ] **Track user retention**
  - [ ] Compare to pre-ad baseline
  - [ ] Adjust frequency if needed

### Month 1
- [ ] **Analyze revenue**
  - [ ] Calculate earnings per user
  - [ ] Compare to expectations
- [ ] **Optimize ad frequency**
  - [ ] Too many complaints? → Reduce frequency
  - [ ] Low revenue? → Consider increasing (carefully)
- [ ] **A/B testing** (optional)
  - [ ] Test different frequencies
  - [ ] Track user retention impact

### Ongoing
- [ ] **Update SDK regularly**
  - [ ] Check for Google Mobile Ads updates
  - [ ] Update via Swift Package Manager
- [ ] **Monitor Apple policy changes**
  - [ ] Privacy changes
  - [ ] Ad guidelines
- [ ] **Optimize based on data**
  - [ ] Seasonal adjustments
  - [ ] User feedback
  - [ ] Revenue goals

---

## 🐛 Troubleshooting Reference

### If ads don't load:
- [ ] Verify Info.plist has GADApplicationIdentifier
- [ ] Check console for error messages
- [ ] Verify internet connection
- [ ] Wait 24-48 hours for new ad units
- [ ] Try test ad unit ID to verify code works

### If ads don't show:
- [ ] Verify you played 3 games
- [ ] Check console: "Presenting interstitial ad"
- [ ] Verify ad loaded successfully (check logs)
- [ ] Check if modal already presented
- [ ] Verify viewController is valid

### If build fails:
- [ ] Verify SDK is properly installed
- [ ] Clean build folder (⇧⌘K)
- [ ] Update package dependencies
- [ ] Check import statements

### If crashes occur:
- [ ] Check crash logs in Xcode
- [ ] Look for memory issues
- [ ] Verify delegate methods are correct
- [ ] Check for nil view controller

---

## 📝 Notes

### Test Ad Unit IDs (Keep for Reference)
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`

### Production Ad Unit IDs
```
App ID: _______________________________________
Interstitial: __________________________________
Banner (future): _______________________________
Rewarded (future): _____________________________
```

### Important Dates
```
Development Started: _______________
First Test Ad Shown: _______________
Production ID Added: _______________
App Submitted: _____________________
App Approved: ______________________
```

### Performance Metrics (Track These)
```
Week 1:
- Impressions: _________
- Fill Rate: ___________%
- eCPM: $__________
- Revenue: $__________

Week 2:
- Impressions: _________
- Fill Rate: ___________%
- eCPM: $__________
- Revenue: $__________

Month 1:
- Total Impressions: _________
- Avg Fill Rate: ___________%
- Avg eCPM: $__________
- Total Revenue: $__________
```

---

## ✨ Success Criteria

You've successfully implemented interstitial ads when:

✅ SDK installed and building without errors  
✅ Test ads showing after 3 games  
✅ Ads close properly and return to game  
✅ Counter resets and next ad loads  
✅ No crashes or memory issues  
✅ Console logs show expected messages  
✅ Production ads configured (for release)  
✅ Info.plist properly configured  
✅ Privacy policy updated  
✅ App Store submission successful  

---

## 🎉 Congratulations!

Once you've checked off all the items, your interstitial ad implementation is complete!

**Remember:**
- Start with test ads
- Monitor user feedback
- Optimize frequency based on data
- Keep SDK updated
- Follow Apple and AdMob policies

**Questions or issues?**
- Check console logs first
- Review documentation files
- Check AdMob support
- Review Apple developer forums

**Good luck with your monetization! 💰**
