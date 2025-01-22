//
//  MainView.swift
//  starter
//
//  Created by marc on 16.01.25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var appState = AppStateManager.shared
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showManageFriends = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("welcome \(appState.username)!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            
            Button {
                showManageFriends = true
            } label: {
                PrimaryButton(text: "Manage Friends")
            }
            
            Button {
                Task {
                    do {
                        try await appState.signOut()
                    } catch {
                        errorMessage = "Failed to sign out: \(error.localizedDescription)"
                        showError = true
                    }
                }
            } label: {
                PrimaryButton(text: "Sign Out")
            }
        }
        .padding()
        .sheet(isPresented: $showManageFriends) {
            ManageFriendsView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
}
