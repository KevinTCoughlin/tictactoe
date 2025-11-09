//
//  GameCenterStatusView.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/8/25.
//

import SwiftUI
import GameKit

/// A view that displays the current Game Center authentication status.
///
/// This view shows whether the player is signed in to Game Center,
/// displays their profile information, and provides options to view
/// the Game Center dashboard.
struct GameCenterStatusView: View {
    
    @ObservedObject private var gameKit = GameKitManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            if gameKit.isAuthenticated {
                authenticatedView
            } else {
                unauthenticatedView
            }
        }
        .padding()
    }
    
    // MARK: - Authenticated View
    
    private var authenticatedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            
            Text("Signed In to Game Center")
                .font(.headline)
            
            if let player = gameKit.localPlayer {
                Text(player.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                gameKit.showGameCenter()
            } label: {
                Label("Open Game Center", systemImage: "gamecontroller")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
    
    // MARK: - Unauthenticated View
    
    private var unauthenticatedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            
            Text("Not Signed In")
                .font(.headline)
            
            if let error = gameKit.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            } else {
                Text("Sign in to Game Center to track achievements and compete with friends.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                gameKit.authenticatePlayer()
            } label: {
                Label("Sign In", systemImage: "gamecontroller")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

// MARK: - Preview

#Preview {
    GameCenterStatusView()
}

#Preview("Authenticated") {
    GameCenterStatusView()
}
