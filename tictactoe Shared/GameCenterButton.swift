//
//  GameCenterButton.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/8/25.
//

import SwiftUI
import GameKit

/// A simple button that shows Game Center authentication status.
///
/// Displays a Game Controller icon that indicates whether the player
/// is signed in to Game Center. Tapping it triggers authentication or
/// shows the Game Center dashboard.
struct GameCenterButton: View {
    
    @ObservedObject private var gameKit = GameKitManager.shared
    
    var body: some View {
        Button {
            handleTap()
        } label: {
            Image(systemName: gameKit.isAuthenticated ? "gamecontroller.fill" : "gamecontroller")
                .font(.system(size: 24))
                .foregroundStyle(gameKit.isAuthenticated ? .green : .secondary)
                .padding(12)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
    
    private func handleTap() {
        if gameKit.isAuthenticated {
            gameKit.showGameCenter()
        } else {
            gameKit.authenticatePlayer()
        }
    }
}

#Preview {
    GameCenterButton()
        .padding()
}
