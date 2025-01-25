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
        print("📱 Initializing PermissionManager...")
        // Only check current status on init, don't request
        Task {
            await checkCurrentStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Requests notification permissions from the user
    func requestNotifications() async throws {
        print("📱 Requesting notification permissions...")
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            print(granted ? "✅ Notification permissions granted" : "❌ Notification permissions denied")
            
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            await checkNotificationStatus()
        } catch {
            print("❌ Error requesting notification permissions:", error)
            throw error
        }
    }
    
    /// Requests contacts permissions from the user
    func requestContacts() async throws {
        print("📱 Requesting contacts permissions...")
        let store = CNContactStore()
        do {
            let granted = try await store.requestAccess(for: .contacts)
            print(granted ? "✅ Contacts permissions granted" : "❌ Contacts permissions denied")
            await checkContactsStatus()
        } catch {
            print("❌ Error requesting contacts permissions:", error)
            throw error
        }
    }
    
    /// Checks the current state of all permissions without requesting
    func checkCurrentStatus() async {
        print("📱 Checking current permission states...")
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
        let newStatus = settings.authorizationStatus == .authorized
        print("📱 Notification permission status: \(newStatus ? "authorized" : "not authorized")")
        hasNotifications = newStatus
    }
    
    private func checkContactsStatus() async {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        let newStatus = status == .authorized
        print("📱 Contacts permission status: \(newStatus ? "authorized" : "not authorized")")
        hasContacts = newStatus
    }
}
