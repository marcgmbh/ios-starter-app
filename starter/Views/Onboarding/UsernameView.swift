//
//  PermissionView.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI

struct UsernameView: View {
    @ObservedObject private var appState = AppStateManager.shared
    @StateObject private var supabase = SupabaseManager.shared
    @State private var username = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        BottomButtonLayout {
            VStack {
                DescriptionText("Choose Username")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                
                InputFieldView(
                    placeholder: "username",
                    text: $username,
                    keyboardType: .default,
                    textContentType: .username
                )
                .font(.system(size: 30, weight: .regular, design: .rounded))
                .padding()
                .multilineTextAlignment(.center)
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        } buttonContent: {
            Button {
                Task {
                    await updateUsername()
                }
            } label: {
                PrimaryButton(text: "Continue", isLoading: isLoading)
            }
            .disabled(username.isEmpty || isLoading)
        }
    }
    
    private func updateUsername() async {
        guard !username.isEmpty else {
            showError = true
            errorMessage = "Please enter a username"
            return
        }
        
        isLoading = true
        showError = false
        
        do {
            guard let userId = supabase.session?.user.id else { return }
            _ = try await APIClient.shared.updateProfile(userId: userId.uuidString, username: username)
            await appState.setUsername(username)
            appState.moveToNextScreen()
        } catch {
            showError = true    
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    UsernameView()
}
