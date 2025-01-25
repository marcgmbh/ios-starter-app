//
//  starterApp.swift
//  starter
//
//  Created by marc on 16.01.25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

@main
struct starterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppStateManager.shared
    
    init() {
        // Initialize Supabase on app launch
        _ = SupabaseManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
