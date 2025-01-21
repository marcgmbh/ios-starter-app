import SwiftUI
import Supabase

@MainActor
struct LoginView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var supabase = SupabaseManager.shared
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showVerification = false
    @FocusState private var isPhoneNumberFocused: Bool
    
    private var formattedPhoneNumber: String {
        phoneNumber.starts(with: "+") ? phoneNumber : "1\(phoneNumber)"
    }
    
    var body: some View {
        BottomButtonLayout {
            VStack {
                DescriptionText(showVerification ? "Enter Code" : "Enter Phone Number")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                
                if !showVerification {
                    phoneNumberInput
                } else {
                    verificationInput
                }
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        } buttonContent: {
            if !showVerification {
                Button {
                    Task {
                        if isTestNumber(formattedPhoneNumber) {
//                            await loginWithEmail()
                        } else {
                            await sendVerificationCode()
                        }
                    }
                } label: {
                    PrimaryButton(text: "Send Code", isLoading: isLoading)
                }
                .disabled(formattedPhoneNumber.count < 8 || isLoading)
            } else {
                Button {
                    Task {
                        await verifyCode()
                    }
                } label: {
                    PrimaryButton(text: "Verify", isLoading: isLoading)
                }
                .disabled(verificationCode.isEmpty || isLoading)
            }
        }
    }
    
    private var phoneNumberInput: some View {
        InputFieldView(
            placeholder: "718-223-4425",
            text: $phoneNumber,
            keyboardType: .phonePad,
            textContentType: .telephoneNumber
        ) { newValue in
            phoneNumber = newValue.filter { $0.isNumber || $0 == "+" }
        }
        .font(.system(size: 30, weight: .regular, design: .rounded))
        .padding()
        .multilineTextAlignment(.center)
        .focused($isPhoneNumberFocused)
    }
    
    private var verificationInput: some View {
        VStack {
            InputFieldView(
                placeholder: "461945",
                text: $verificationCode,
                keyboardType: .phonePad,
                textContentType: .oneTimeCode
            ) { newValue in
                verificationCode = newValue.filter { $0.isNumber }
            }
            .font(.system(size: 30, weight: .regular, design: .rounded))
            .padding()
            .multilineTextAlignment(.center)
            .focused($isPhoneNumberFocused)
            
            Button {
                showVerification = false
                verificationCode = ""
            } label: {
                Text("Back")
                    .foregroundColor(.blue)
            }
        }
    }
    
    private func isTestNumber(_ number: String) -> Bool {
        ["+16572145917", "16572145917", "6572145917"].contains(number)
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
            appState.setLoggedIn(true)
            appState.moveToNextScreen()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
}
