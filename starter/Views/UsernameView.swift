//
//  UsernameView.swift
//  starter
//
//  Created by marc on 16.01.25.
//

import SwiftUI

struct UsernameView: View {
    @EnvironmentObject private var appState: AppState
    @State private var username = ""
    @State private var showError = false
    @FocusState private var isUsernameFocused: Bool
    
    var body: some View {
        BottomButtonLayout {
            VStack(spacing: 20) {
                DescriptionText(text: "Choose Username")
                
                InputFieldView(
                    placeholder: "Username",
                    text: $username,
                    textContentType: .username
                )
                
                if showError {
                    Text("Please enter a valid username")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        } buttonContent: {
            Button(action: handleUsername) {
                PrimaryButton(myText: "Continue")
            }
            .disabled(username.isEmpty)
        }
    }
    
    private func handleUsername() {
        guard username.count >= 3 else {
            showError = true
            return
        }
        
        appState.username = username
        appState.moveToNextScreen()
    }
}

#Preview {
    UsernameView()
}
