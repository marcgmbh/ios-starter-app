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
        print("📱 App launching...")
        FirebaseApp.configure()
        print("📱 Initializing notification manager...")
        NotificationManager.shared.initialize()
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        NotificationManager.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        NotificationManager.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}
