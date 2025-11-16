//
//  SoundManager.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/9/25.
//

import AVFoundation
import Combine

#if os(iOS)
import UIKit
#endif

/// Manages audio playback for game sounds using modern Swift concurrency.
///
/// This manager follows Apple's audio design guidelines:
/// - Uses system sounds for quick, non-intrusive feedback
/// - Respects user preferences for haptics and sound
/// - Provides spatial audio effects where appropriate
/// - Handles audio session configuration automatically
@MainActor
final class SoundManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance of the sound manager.
    static let shared = SoundManager()
    
    // MARK: - Sound Types
    
    /// Available sound effects in the game.
    enum SoundEffect: String, CaseIterable {
        case turnPlay = "turn_play"
        case gameWin = "game_win"
        case gameDraw = "game_draw"
        case gameReset = "game_reset"
        
        /// The file extension for this sound.
        var fileExtension: String {
            switch self {
            case .turnPlay: return "caf"
            case .gameWin: return "caf"
            case .gameDraw: return "caf"
            case .gameReset: return "caf"
            }
        }
        
        /// The volume level for this sound (0.0 to 1.0).
        var volume: Float {
            switch self {
            case .turnPlay: return 0.4
            case .gameWin: return 0.6
            case .gameDraw: return 0.5
            case .gameReset: return 0.3
            }
        }
    }
    
    // MARK: - Published Properties
    
    /// Whether sound effects are enabled.
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "SoundEnabled")
            if !isSoundEnabled {
                stopAllSounds()
            }
        }
    }
    
    /// Whether haptic feedback is enabled (iOS only).
    @Published var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: "HapticsEnabled")
        }
    }
    
    // MARK: - Private Properties
    
    /// Cache of prepared audio players for each sound effect.
    private var audioPlayers: [SoundEffect: AVAudioPlayer] = [:]
    
    /// System sound IDs for fallback on older systems or when using system sounds.
    private var systemSoundIDs: [SoundEffect: SystemSoundID] = [:]
    
    #if os(iOS)
    /// Haptic feedback generators for different interaction types.
    private lazy var selectionFeedback = UISelectionFeedbackGenerator()
    private lazy var impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private lazy var notificationFeedback = UINotificationFeedbackGenerator()
    #endif
    
    // MARK: - Initialization
    
    private override init() {
        // Load user preferences
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "SoundEnabled") as? Bool ?? true
        self.isHapticsEnabled = UserDefaults.standard.object(forKey: "HapticsEnabled") as? Bool ?? true
        
        super.init()
        
        Task {
            await setupAudioSession()
            await preloadSounds()
            prepareHaptics()
        }
    }
    
    // MARK: - Audio Session Setup
    
    /// Configures the audio session for optimal playback.
    private func setupAudioSession() async {
        #if os(iOS) || os(tvOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Use ambient category to allow mixing with other audio
            // and to respect the silent switch
            try audioSession.setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            
            try audioSession.setActive(true)
            
            print("✅ Sound: Audio session configured")
        } catch {
            print("❌ Sound: Failed to configure audio session - \(error.localizedDescription)")
        }
        #endif
    }
    
    // MARK: - Sound Preloading
    
    /// Preloads all sound effects for instant playback.
    private func preloadSounds() async {
        for soundEffect in SoundEffect.allCases {
            await loadSound(soundEffect)
        }
    }
    
    /// Loads a specific sound effect into memory.
    private func loadSound(_ soundEffect: SoundEffect) async {
        // Try to load as audio file first (preferred for quality and control)
        if let url = soundURL(for: soundEffect) {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = soundEffect.volume
                audioPlayers[soundEffect] = player
                print("✅ Sound: Loaded \(soundEffect.rawValue)")
            } catch {
                print("⚠️ Sound: Failed to load \(soundEffect.rawValue) - \(error.localizedDescription)")
                // Fall back to system sounds
                await loadSystemSound(soundEffect, url: url)
            }
        } else {
            // Sound file doesn't exist yet, use synthesized system sounds
            print("ℹ️ Sound: No file for \(soundEffect.rawValue), will synthesize")
        }
    }
    
    /// Loads a sound as a system sound for fallback.
    private func loadSystemSound(_ soundEffect: SoundEffect, url: URL) async {
        var soundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        
        if status == kAudioServicesNoError {
            systemSoundIDs[soundEffect] = soundID
            print("✅ Sound: Loaded \(soundEffect.rawValue) as system sound")
        } else {
            print("❌ Sound: Failed to load system sound for \(soundEffect.rawValue)")
        }
    }
    
    /// Returns the URL for a sound effect file.
    private func soundURL(for soundEffect: SoundEffect) -> URL? {
        Bundle.main.url(
            forResource: soundEffect.rawValue,
            withExtension: soundEffect.fileExtension
        )
    }
    
    // MARK: - Haptics Setup
    
    /// Prepares haptic feedback generators.
    private func prepareHaptics() {
        #if os(iOS)
        guard isHapticsEnabled else { return }
        
        selectionFeedback.prepare()
        impactFeedback.prepare()
        notificationFeedback.prepare()
        
        print("✅ Sound: Haptics prepared")
        #endif
    }
    
    // MARK: - Public Playback Methods
    
    /// Plays a sound effect with optional haptic feedback.
    ///
    /// - Parameters:
    ///   - soundEffect: The sound effect to play.
    ///   - withHaptics: Whether to trigger haptic feedback (iOS only).
    func play(_ soundEffect: SoundEffect, withHaptics: Bool = true) {
        guard isSoundEnabled else { return }
        
        // Try AVAudioPlayer first for best quality
        if let player = audioPlayers[soundEffect] {
            player.currentTime = 0
            player.play()
        }
        // Fall back to system sound
        else if let soundID = systemSoundIDs[soundEffect] {
            AudioServicesPlaySystemSound(soundID)
        }
        // If no sound file exists, use synthesized feedback
        else {
            playSynthesizedSound(for: soundEffect)
        }
        
        // Trigger haptics if requested
        if withHaptics {
            triggerHaptic(for: soundEffect)
        }
    }
    
    /// Plays a turn sound effect.
    func playTurn() {
        play(.turnPlay)
    }
    
    /// Plays the winning sound effect.
    func playWin() {
        play(.gameWin, withHaptics: true)
    }
    
    /// Plays the draw sound effect.
    func playDraw() {
        play(.gameDraw, withHaptics: true)
    }
    
    /// Plays the reset sound effect.
    func playReset() {
        play(.gameReset, withHaptics: false)
    }
    
    // MARK: - Synthesized Sounds
    
    /// Plays a synthesized system sound when custom sounds aren't available.
    private func playSynthesizedSound(for soundEffect: SoundEffect) {
        switch soundEffect {
        case .turnPlay:
            // Light tap sound
            AudioServicesPlaySystemSound(1104) // Tock
            
        case .gameWin:
            // Success sound
            AudioServicesPlaySystemSound(1025) // ReceivedMessage
            
        case .gameDraw:
            // Neutral sound
            AudioServicesPlaySystemSound(1054) // JBL_Begin
            
        case .gameReset:
            // Subtle click
            AudioServicesPlaySystemSound(1123) // Tink
        }
    }
    
    // MARK: - Haptic Feedback
    
    /// Triggers haptic feedback appropriate for the sound effect.
    private func triggerHaptic(for soundEffect: SoundEffect) {
        #if os(iOS)
        guard isHapticsEnabled else { return }
        
        switch soundEffect {
        case .turnPlay:
            selectionFeedback.selectionChanged()
            
        case .gameWin:
            notificationFeedback.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
            
        case .gameDraw:
            notificationFeedback.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.warning)
            
        case .gameReset:
            impactFeedback.impactOccurred(intensity: 0.5)
        }
        #endif
    }
    
    /// Triggers a light selection haptic (for UI interactions).
    func triggerSelectionHaptic() {
        #if os(iOS)
        guard isHapticsEnabled else { return }
        selectionFeedback.selectionChanged()
        #endif
    }
    
    /// Triggers an impact haptic with the specified intensity.
    func triggerImpactHaptic(intensity: CGFloat = 1.0) {
        #if os(iOS)
        guard isHapticsEnabled else { return }
        impactFeedback.impactOccurred(intensity: intensity)
        #endif
    }
    
    // MARK: - Playback Control
    
    /// Stops all currently playing sounds.
    private func stopAllSounds() {
        audioPlayers.values.forEach { player in
            if player.isPlaying {
                player.stop()
            }
        }
    }
    
    /// Stops all currently playing sounds (nonisolated for cleanup).
    private nonisolated func stopAllSoundsSync() {
        // Access the players dictionary safely
        Task { @MainActor in
            audioPlayers.values.forEach { player in
                if player.isPlaying {
                    player.stop()
                }
            }
        }
    }
    
    /// Reloads all sounds (useful after enabling sound).
    func reloadSounds() {
        Task {
            await preloadSounds()
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopAllSoundsSync()
        
        // Clean up system sounds
        for (_, soundID) in systemSoundIDs {
            AudioServicesDisposeSystemSoundID(soundID)
        }
    }
}

// MARK: - Sound File Generation Helper

extension SoundManager {
    
    /// Prints instructions for creating sound files.
    ///
    /// This is a development helper that shows developers what sound files
    /// to create and where to place them in the bundle.
    func printSoundFileInstructions() {
        print("""
        
        📢 Sound File Setup Instructions
        ================================
        
        To use custom sound files instead of system sounds:
        
        1. Create or obtain the following audio files (recommended: .caf format):
           • turn_play.caf - Light, quick tap sound (100-200ms)
           • game_win.caf - Celebratory chime (500-1000ms)
           • game_draw.caf - Neutral tone (300-500ms)
           • game_reset.caf - Subtle click (50-100ms)
        
        2. Convert to Core Audio Format (.caf) for best performance:
           afconvert -f caff -d LEI16 input.wav output.caf
        
        3. Add files to your Xcode project and ensure they're included
           in the target's "Copy Bundle Resources" build phase.
        
        4. Recommended audio specifications:
           • Format: Core Audio Format (.caf)
           • Sample Rate: 44.1 kHz or 48 kHz
           • Bit Depth: 16-bit
           • Channels: Mono (stereo for music)
        
        Until custom files are added, the app uses synthesized system sounds.
        
        ================================
        """)
    }
}
