//
//  SoundSettingsView.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/9/25.
//

import SwiftUI

/// A view for controlling sound and haptic feedback settings.
///
/// This view follows Apple's Human Interface Guidelines for settings,
/// providing clear labels, appropriate controls, and immediate feedback.
struct SoundSettingsView: View {
    
    // MARK: - State
    
    @ObservedObject private var soundManager = SoundManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            settingsContent
                .navigationTitle("Sound & Haptics")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        #elseif os(macOS)
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Sound & Haptics")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            
            Divider()
            
            // Content
            settingsContent
                .padding()
        }
        .frame(width: 400, height: 300)
        #else
        settingsContent
        #endif
    }
    
    // MARK: - Settings Content
    
    @ViewBuilder
    private var settingsContent: some View {
        #if os(iOS)
        Form {
            soundSection
            hapticsSection
            testSection
        }
        #elseif os(macOS)
        Form {
            soundSection
            testSection
        }
        .formStyle(.grouped)
        #else
        Form {
            soundSection
            testSection
        }
        #endif
    }
    
    // MARK: - Sound Section
    
    private var soundSection: some View {
        Section {
            Toggle(isOn: $soundManager.isSoundEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sound Effects")
                            .font(.body)
                        
                        Text("Play sounds for moves and game events")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.blue)
                }
            }
            .onChange(of: soundManager.isSoundEnabled) { _, isEnabled in
                if isEnabled {
                    // Play a test sound when enabling
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        soundManager.playTurn()
                    }
                }
            }
        } header: {
            Text("Audio")
        }
    }
    
    // MARK: - Haptics Section (iOS only)
    
    #if os(iOS)
    private var hapticsSection: some View {
        Section {
            Toggle(isOn: $soundManager.isHapticsEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Haptic Feedback")
                            .font(.body)
                        
                        Text("Feel tactile responses for game actions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "hand.tap.fill")
                        .foregroundStyle(.purple)
                }
            }
            .onChange(of: soundManager.isHapticsEnabled) { _, isEnabled in
                if isEnabled {
                    // Trigger a test haptic when enabling
                    soundManager.triggerSelectionHaptic()
                }
            }
        } header: {
            Text("Haptics")
        } footer: {
            Text("Haptic feedback requires a supported device.")
                .font(.caption)
        }
    }
    #endif
    
    // MARK: - Test Section
    
    private var testSection: some View {
        Section {
            Button {
                soundManager.playTurn()
            } label: {
                Label("Test Turn Sound", systemImage: "play.circle.fill")
            }
            .disabled(!soundManager.isSoundEnabled)
            
            Button {
                soundManager.playWin()
            } label: {
                Label("Test Win Sound", systemImage: "party.popper.fill")
            }
            .disabled(!soundManager.isSoundEnabled)
            
            Button {
                soundManager.playDraw()
            } label: {
                Label("Test Draw Sound", systemImage: "equal.circle.fill")
            }
            .disabled(!soundManager.isSoundEnabled)
            
            Button {
                soundManager.playReset()
            } label: {
                Label("Test Reset Sound", systemImage: "arrow.counterclockwise.circle.fill")
            }
            .disabled(!soundManager.isSoundEnabled)
        } header: {
            Text("Test Sounds")
        } footer: {
            Text("Tap any button to preview the sound effect.")
                .font(.caption)
        }
    }
}

// MARK: - Preview

#Preview {
    SoundSettingsView()
}
