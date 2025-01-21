import SwiftUI
import UserNotifications
import Contacts

/// Manages app permissions for notifications and contacts
@MainActor
final class PermissionManager: ObservableObject {
    // MARK: - Properties
    
    static let shared = PermissionManager()
    
    @Published var hasNotifications = false
    @Published var hasContacts = false
    
    // MARK: - Initialization
    
    private init() {
        Task {
            await checkPermissionStates()
        }
    }
    
    // MARK: - Public Methods
    
    /// Requests notification permissions from the user
    func requestNotifications() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            hasNotifications = granted
            return granted
        } catch {
            print("Failed to request notifications:", error.localizedDescription)
            return false
        }
    }
    
    /// Requests contacts permissions from the user
    func requestContacts() async -> Bool {
        let store = CNContactStore()
        do {
            let granted = try await store.requestAccess(for: .contacts)
            hasContacts = granted
            return granted
        } catch {
            print("Failed to request contacts access:", error.localizedDescription)
            return false
        }
    }
    
    /// Checks the current state of all permissions
    func checkPermissionStates() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.checkNotificationStatus()
            }
            group.addTask {
                await self.checkContactsStatus()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        hasNotifications = settings.authorizationStatus == .authorized
    }
    
    private func checkContactsStatus() async {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        hasContacts = status == .authorized
    }
}
