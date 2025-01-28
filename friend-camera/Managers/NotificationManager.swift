//
//  NotificationManager.swift
//  starter
//
//  Created by marc on 25.01.25.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import OSLog

@Observable final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private var lastSavedToken: String?
    
    private override init() {
        super.init()
    }
    
    func initialize() {
        print("📱 Initializing NotificationManager...")
        setupNotifications()
        
        // Check if we already have notification permission
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.authorizationStatus == .authorized {
                print("📱 Notifications already authorized, registering for remote notifications")
                registerForRemoteNotifications()
            } else {
                print("📱 Notifications not authorized: \(settings.authorizationStatus.rawValue)")
            }
        }
    }
    
    private func setupNotifications() {
        print("📱 Setting up notification delegates")
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
    
    func registerForRemoteNotifications() {
        print("📱 Registering for remote notifications")
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            // Don't fetch FCM token here, it will be fetched when we get APNS token
        }
    }
    
    func fetchAndUpdateFCMToken() {
        print("📱 Fetching FCM token")
        // First make sure we're registered for remote notifications
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // Then get FCM token
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("❌ Error fetching FCM token:", error)
                return
            }
            
            guard let token = token else {
                print("❌ Received nil FCM token")
                return
            }
            
            print("✅ Successfully fetched FCM token")
            Task { @MainActor [weak self] in
                await self?.saveFCMTokenIfNeeded(token)
            }
        }
    }
    
    private func saveFCMTokenIfNeeded(_ token: String) async {
        print("📱 Checking if FCM token needs to be saved")
        
        // Check login state
        guard let session = await SupabaseManager.shared.session else {
            print("📱 User not logged in, skipping token save")
            return
        }
        
        guard token != lastSavedToken else {
            print("📱 Token unchanged, skipping save")
            return
        }
        
        do {
            try await SupabaseManager.shared.saveFCMToken(token)
            lastSavedToken = token
            print("✅ Successfully saved FCM token")
        } catch {
            print("❌ Failed to save FCM token:", error)
            lastSavedToken = nil
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📱 Received notification while app in foreground")
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("📱 User tapped notification")
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("❌ Received nil FCM token from delegate")
            return
        }
        
        print("📱 FCM token updated from delegate")
        Task { @MainActor in
            await saveFCMTokenIfNeeded(token)
        }
    }
}

// MARK: - UIApplicationDelegate
extension NotificationManager {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("📱 Received APNS token")
        Messaging.messaging().apnsToken = deviceToken
        fetchAndUpdateFCMToken()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications:", error)
    }
}
