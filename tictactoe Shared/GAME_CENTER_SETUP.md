# Game Center Setup Guide

## Required Steps to Enable Game Center

### 1. Add Game Center Capability

In Xcode:
1. Select your project in the Project Navigator
2. Select your app target
3. Go to the **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Game Center**

### 2. Configure App ID in Developer Portal

1. Go to [Apple Developer](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** > Your App ID
4. Enable **Game Center**
5. Save changes

### 3. Configure in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Services** > **Game Center**
4. Enable Game Center for your app
5. Configure leaderboards and achievements (optional)

### 4. Test with Sandbox Account

1. Go to **Settings** > **Game Center** on your device
2. Sign out of your regular account
3. Create a sandbox tester account in App Store Connect:
   - Go to **Users and Access** > **Sandbox Testers**
   - Create a new tester account
4. Sign in with the sandbox account on your device

## Usage in Your App

The `GameKitManager` is already integrated and will authenticate automatically when the app launches.

### Check Authentication Status

```swift
// In any SwiftUI View
@ObservedObject var gameKit = GameKitManager.shared

var body: some View {
    if gameKit.isAuthenticated {
        Text("Welcome, \(gameKit.localPlayer?.displayName ?? "Player")!")
    } else {
        Text("Sign in to Game Center")
    }
}
```

### Show Game Center Dashboard

```swift
Button("Show Game Center") {
    GameKitManager.shared.showGameCenter()
}
```

### Show Specific Views

```swift
// Show leaderboards
GameKitManager.shared.showGameCenter(state: .leaderboards)

// Show achievements
GameKitManager.shared.showGameCenter(state: .achievements)

// Show challenges
GameKitManager.shared.showGameCenter(state: .challenges)
```

## Future Enhancements

You can extend the `GameKitManager` to add:

- **Leaderboards**: Submit scores and display rankings
- **Achievements**: Track and unlock achievements
- **Multiplayer**: Enable turn-based or real-time multiplayer
- **Challenges**: Issue challenges to friends

## Testing

1. Run the app
2. You should see the Game Center login prompt
3. Sign in with your sandbox tester account
4. Check the console for authentication messages:
   - ✅ Success: "Game Center: Authenticated as [Name]"
   - ❌ Error: "Game Center Error: [Error message]"
   - ⚠️ Cancelled: "Game Center: Authentication cancelled"

## Troubleshooting

- **No login prompt appears**: Check that Game Center capability is added
- **Authentication fails**: Verify sandbox tester account is set up correctly
- **Crashes on macOS**: Ensure your macOS app target also has Game Center enabled
