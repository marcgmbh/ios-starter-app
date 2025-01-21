import SwiftUI
import Contacts
import UserNotifications

struct PermissionsView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var viewModel = PermissionsViewModel()
    
    var body: some View {
        BottomButtonLayout {
            VStack(spacing: 20) {
                headerSection
                permissionsSection
            }
        } buttonContent: {
            Button {
                if viewModel.hasAnyPermission {
                    appState.moveToNextScreen()
                }
            } label: {
                PrimaryButton(text: "Continue")
            }
            .disabled(!viewModel.hasAnyPermission)
        }
        .onAppear {
            viewModel.checkCurrentPermissions()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            DescriptionText("Permissions")
                .font(.system(size: 35, weight: .black, design: .rounded))
            Text("We need a few permissions to get you started:")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private var permissionsSection: some View {
        VStack(spacing: 15) {
            PermissionButton(
                icon: "💬",
                title: "Notifications",
                description: "To keep you updated",
                isGranted: viewModel.hasNotifications,
                action: viewModel.requestNotifications
            )
            
            PermissionButton(
                icon: "🤝",
                title: "Contacts",
                description: "To find your friends",
                isGranted: viewModel.hasContacts,
                action: viewModel.requestContacts
            )
        }
        .padding(.top)
    }
}

@MainActor
final class PermissionsViewModel: ObservableObject {
    @Published var hasNotifications = false
    @Published var hasContacts = false
    
    var hasAnyPermission: Bool {
        hasNotifications || hasContacts
    }
    
    func checkCurrentPermissions() {
        Task {
            await checkNotificationStatus()
            await checkContactsStatus()
        }
    }
    
    func requestNotifications() {
        Task {
            guard let granted = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) else { return }
            hasNotifications = granted
        }
    }
    
    func requestContacts() {
        Task {
            guard let granted = try? await CNContactStore().requestAccess(for: .contacts) else { return }
            hasContacts = granted
        }
    }
    
    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        hasNotifications = settings.authorizationStatus == .authorized
    }
    
    private func checkContactsStatus() async {
        hasContacts = CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
}

struct PermissionButton: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                
                Image(systemName: isGranted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isGranted ? .green : .gray)
                    .font(.title2)
                    .symbolEffect(.bounce, value: isGranted)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: isGranted ? .green.opacity(0.3) : .gray.opacity(0.3), radius: 6)
                    .overlay {
                        if isGranted {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(.green, lineWidth: 2)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

#Preview {
    PermissionsView()
}
