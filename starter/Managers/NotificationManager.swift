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

@Observable final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private var lastSavedToken: String?
    
    private override init() {
        super.init()
    }
    
    func initialize() {
        print("📱 Initializing NotificationManager...")
        setupNotifications()
        requestNotificationPermissions()
    }
    
    private func setupNotifications() {
        print("📱 Setting up notification delegates...")
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Don't try to get FCM token here since we need APNs token first
        print("📱 Waiting for APNs token before requesting FCM token...")
    }
    
    private func requestNotificationPermissions() {
        print("📱 Requesting notification permissions...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            print("📱 Notification permission granted:", granted)
            if let error = error {
                print("❌ Notification permission error:", error)
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    print("📱 Registering for remote notifications...")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("⚠️ Notification permissions denied by user")
            }
        }
    }
    
    func fetchAndUpdateFCMToken() {
        print("📱 Fetching FCM token...")
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("❌ Error fetching FCM token:", error)
                return
            }
            
            guard let token = token else {
                print("❌ Received nil FCM token")
                return
            }
            
            print("✅ Fetched FCM token:", token)
            Task { @MainActor [weak self] in
                await self?.saveFCMTokenIfNeeded(token)
            }
        }
    }
    
    private func saveFCMTokenIfNeeded(_ token: String) async {
        guard await SupabaseManager.shared.session != nil else {
            print("ℹ️ User not logged in, skipping token save")
            return
        }
        
        guard token != lastSavedToken else {
            print("ℹ️ Token unchanged, skipping save")
            return
        }
        
        do {
            try await SupabaseManager.shared.saveFCMToken(token)
            lastSavedToken = token
            print("✅ FCM token saved successfully")
        } catch {
            print("❌ Failed to save FCM token:", error)
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
        let userInfo = notification.request.content.userInfo
        print("📱 Received notification while app in foreground:", userInfo)
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("📱 User tapped notification:", userInfo)
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("❌ Received nil FCM token")
            return
        }
        
        print("📱 FCM token updated:", token)
        Task { @MainActor in
            await self.saveFCMTokenIfNeeded(token)
        }
    }
}
