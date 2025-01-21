//
//  PermissionsView.swift
//  starter
//
//  Created by marc on 20.01.25.
//

import SwiftUI
import Contacts
import UserNotifications

struct PermissionsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isNotificationsToggled: Bool = false
    @State private var areContactsApproved: Bool = false
    @State private var contactsStatus: CNAuthorizationStatus = .notDetermined
    
    var body: some View {
        BottomButtonLayout {
            VStack(spacing: 20) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    DescriptionText(text: "Permissions")
                        .font(.system(size: 35, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("We need a few permissions to get you started:")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack(spacing: 15) {
                    // Notifications Permission
                    Button(action: {
                        requestPushNotificationAccess { granted in
                            if granted {
                                isNotificationsToggled.toggle()
                            }
                        }
                    }) {
                        PermissionCard(
                            icon: "💬",
                            title: "Notifications",
                            description: "To keep you updated",
                            isEnabled: isNotificationsToggled,
                            allPermissionsEnabled: isNotificationsToggled && areContactsApproved
                        )
                    }
                    
                    // Contacts Permission
                    Button(action: {
                        checkContactsPermission { granted in
                            if granted {
                                areContactsApproved.toggle()
                            }
                        }
                    }) {
                        PermissionCard(
                            icon: "🤝",
                            title: "Contacts",
                            description: "To find your friends",
                            isEnabled: areContactsApproved,
                            allPermissionsEnabled: isNotificationsToggled && areContactsApproved
                        )
                    }
                }
                .padding(.top)
                
                Spacer()
            }
        } buttonContent: {
            Button(action: {
                if isNotificationsToggled || areContactsApproved {
                    appState.moveToNextScreen()
                }
            }) {
                PrimaryButton(myText: "Continue")
            }
            .disabled(!isNotificationsToggled && !areContactsApproved)
        }
    }
    
    private func requestPushNotificationAccess(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    private func checkContactsPermission(completion: @escaping (Bool) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        contactsStatus = status
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    let allPermissionsEnabled: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: allPermissionsEnabled ? .green.opacity(0.3) : .gray.opacity(0.3), radius: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(allPermissionsEnabled ? Color.green : Color.clear, lineWidth: 2)
                )
                .frame(height: 80)
                .padding(.horizontal)
            
            HStack {
                Text(icon)
                    .font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: .constant(isEnabled))
                    .labelsHidden()
                    .padding(.trailing)
                    .allowsHitTesting(false)
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    PermissionsView()
}
