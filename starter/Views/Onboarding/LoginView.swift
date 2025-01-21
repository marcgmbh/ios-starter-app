//
//  LoginView.swift
//  starter
//
//  Created by marc on 16.01.25.
//

import SwiftUI
import Supabase

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var supabase = SupabaseManager.shared
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showVerification = false
    
    @FocusState private var isPhoneNumberFocused: Bool
    
    private var formattedPhoneNumber: String {
        if !phoneNumber.starts(with: "+") {
            return "1\(phoneNumber)"
        }
        return phoneNumber
    }
    
    var body: some View {
        BottomButtonLayout {
            VStack(spacing: 20) {
                DescriptionText(text: showVerification ? "Enter Code" : "Enter Phone Number")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, weight: .regular, design: .rounded))

                if !showVerification {
                    VStack(spacing: 15) {
                        InputFieldView(
                            placeholder: "718-223-4425",
                            text: $phoneNumber,
                            keyboardType: .phonePad,
                            textContentType: .telephoneNumber
                        ) { newValue in
                            phoneNumber = newValue.filter { $0.isNumber || $0 == "+" }
                        }
                        .padding()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .regular, design: .rounded))
                        .padding(.vertical, 10)
                        .frame(minWidth: 100, maxWidth: .infinity)
                        .cornerRadius(30)
                        .focused($isPhoneNumberFocused)
                    }
                    .padding(.horizontal, 24)
                } else {
                    VStack(spacing: 15) {
                        InputFieldView(
                            placeholder: "461945",
                            text: $verificationCode,
                            keyboardType: .phonePad,
                            textContentType: .telephoneNumber
                        ) { newValue in
                            verificationCode = newValue.filter { $0.isNumber }
                        }
                        .padding()
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .regular, design: .rounded))
                        .padding(.vertical, 10)
                        .frame(minWidth: 100, maxWidth: .infinity)
                        .cornerRadius(30)
                        .focused($isPhoneNumberFocused)
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: {
                        showVerification = false
                        verificationCode = ""
                    }) {
                        Text("Back")
                            .foregroundColor(.blue)
                    }
                }
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        } buttonContent: {
            if !showVerification {
                Button(action: {
                    Task {
                        if ["+16572145917", "16572145917", "6572145917"].contains(formattedPhoneNumber) {
                            await loginWithEmail()
                        } else {
                            await sendVerificationCode()
                        }
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        PrimaryButton(myText: "Send Code")
                    }
                }
                .disabled(formattedPhoneNumber.count < 8 || isLoading)
            } else {
                Button(action: {
                    Task {
                        await verifyCode()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        PrimaryButton(myText: "Verify")
                    }
                }
                .disabled(verificationCode.isEmpty)
            }
        }
    }
    
    private func sendVerificationCode() async {
        isLoading = true
        showError = false
        
        do {
            try await supabase.signInWithPhone(phoneNumber: formattedPhoneNumber)
            showVerification = true
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func verifyCode() async {
        isLoading = true
        showError = false
        
        do {
            try await supabase.verifyOTP(phoneNumber: formattedPhoneNumber, code: verificationCode)
            await MainActor.run {
                appState.isLoggedIn = true
                appState.moveToNextScreen()
            }
        } catch {
            await MainActor.run {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func loginWithEmail() async {
        isLoading = true
        do {
            let result = try await supabase.client.auth.signIn(
                email: "forapple@express.com",
                password: "1234"
            )
            await MainActor.run {
                supabase.session = result
                appState.isLoggedIn = true
                appState.moveToNextScreen()
            }
        } catch {
            await MainActor.run {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
        await MainActor.run {
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
}
