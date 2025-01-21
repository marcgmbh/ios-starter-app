//
//  PermissionManager.swift
//  starter
//
//  Created by marc on 21.01.25.
//

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
    func requestNotifications() async throws {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            throw error
        }
    }
    
    /// Requests contacts permissions from the user
    func requestContacts() async throws {
        let store = CNContactStore()
        do {
            try await store.requestAccess(for: .contacts)
        } catch {
            throw error
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
