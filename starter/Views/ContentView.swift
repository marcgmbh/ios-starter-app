//
//  ContentView.swift
//  starter
//
//  Created by marc on 16.01.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppStateManager.shared
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
        }
        .tint(.primary)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch appState.currentScreen {
        case .login:
            LoginView()
                .transition(.opacity.combined(with: .move(edge: .leading)))
        case .notifications, .contacts, .permissions:
            PermissionsView()
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .username:
            UsernameView()
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .main, .complete:
            MainView()
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
