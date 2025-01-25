//
//  AppDelegate.swift
//  starter
//
//  Created by marc on 25.01.25.
//

import UIKit
import FirebaseMessaging
import UserNotifications
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("📱 App launching, configuring Firebase...")
        FirebaseApp.configure()
        print("📱 Initializing notification manager...")
        NotificationManager.shared.initialize()
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("📱 Received APNs token")
        
        // Convert token to string for logging
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 APNs token:", tokenString)
        
        // Set APNs token which will trigger FCM token generation
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications:", error)
    }
}
