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
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome \(appState.username)!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You're all set!")
                .font(.title2)
                .foregroundColor(.gray)
            
            Spacer()
            
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
            .padding(.horizontal, 40)
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
}
