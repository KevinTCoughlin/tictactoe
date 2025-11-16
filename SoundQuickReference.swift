//
//  SoundQuickReference.swift
//  tictactoe Shared
//
//  Quick reference for sound implementation
//

/*

SOUND SYSTEM QUICK REFERENCE
============================

BASIC USAGE
-----------

// Play sounds anywhere in your code:
SoundManager.shared.playTurn()      // When X or O placed
SoundManager.shared.playWin()       // When player wins
SoundManager.shared.playDraw()      // When game draws
SoundManager.shared.playReset()     // When game resets

// Trigger haptics (iOS only):
SoundManager.shared.triggerSelectionHaptic()
SoundManager.shared.triggerImpactHaptic(intensity: 0.7)


CHECK USER PREFERENCES
----------------------

if SoundManager.shared.isSoundEnabled {
    // Sound is on
}

if SoundManager.shared.isHapticsEnabled {
    // Haptics are on (iOS only)
}


SHOW SETTINGS UI
----------------

import SwiftUI

struct YourView: View {
    @State private var showingSettings = false
    
    var body: some View {
        Button("Settings") {
            showingSettings = true
        }
        .sheet(isPresented: $showingSettings) {
            SoundSettingsView()
        }
    }
}


CUSTOM SOUND FILES (OPTIONAL)
------------------------------

Create these files and add to Xcode project:
• turn_play.caf   - Quick tap (100-200ms, 0.4 volume)
• game_win.caf    - Celebratory (500-1000ms, 0.6 volume)
• game_draw.caf   - Neutral (300-500ms, 0.5 volume)
• game_reset.caf  - Soft click (50-100ms, 0.3 volume)

Convert audio files to .caf:
  afconvert -f caff -d LEI16 input.wav output.caf

FALLBACK: System sounds play if custom files not found.


IMPLEMENTATION DETAILS
----------------------

Already integrated in GameScene.swift:
✅ placeMark(at:)      → playTurn()
✅ handleGameOver()    → playWin() or playDraw()
✅ resetGame()         → playReset()


SOUND EVENTS & HAPTICS
----------------------

Event        | Sound ID  | Haptic Type       | Volume
-------------|-----------|-------------------|-------
Turn Play    | 1104      | Selection         | 0.4
Game Win     | 1025      | Success           | 0.6
Game Draw    | 1054      | Warning           | 0.5
Game Reset   | 1123      | Impact (0.5)      | 0.3


DEBUGGING
---------

Print current status:
  SoundManager.shared.printSoundFileInstructions()

Watch console for:
  ✅ Sound: Audio session configured
  ✅ Sound: Loaded turn_play
  ✅ Haptics: Prepared


ARCHITECTURE
------------

SoundManager
├── @MainActor isolated
├── ObservableObject for SwiftUI
├── Preloads all sounds at launch
├── Caches AVAudioPlayer instances
├── Falls back to system sounds
├── Manages haptic generators (iOS)
└── Persists preferences to UserDefaults


APPLE GUIDELINES COMPLIANCE
----------------------------

✅ Brief, unobtrusive sounds
✅ Ambient audio session (mixes with other apps)
✅ Respects silent switch (iOS)
✅ User controls for sound/haptics
✅ Synchronized haptic feedback
✅ Appropriate volume levels
✅ Accessible (can disable independently)


CROSS-PLATFORM NOTES
---------------------

Platform | Sound | Haptics | Settings UI
---------|-------|---------|-------------
iOS      | ✅     | ✅       | ✅
macOS    | ✅     | ❌       | ✅ (no haptics)
tvOS     | ✅     | ❌       | Limited


MORE INFO
---------

See: SOUND_SYSTEM_GUIDE.md
See: SOUND_IMPLEMENTATION_SUMMARY.md

*/
