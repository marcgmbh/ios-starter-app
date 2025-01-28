//
//  AppStateManager.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI
import UserNotifications
import Contacts
import Auth

enum AppScreen: String {
    case login
    case username
    case notifications
    case contacts
    case permissions
    case main
    case complete
}

@MainActor
final class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var currentScreen: AppScreen = .login
    @Published var isLoggedIn = false
    @Published var username = ""
    @Published var hasPermissions = false
    
    private let permissionManager = PermissionManager.shared
    
    private init() {
        print("📱 Initializing AppStateManager...")
        // Load saved state
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        
        // Check permissions and session state
        Task {
            await checkPermissionStates()
            await determineInitialScreen()
        }
    }
    
    @MainActor
    private func determineInitialScreen() async {
        // Check if we have a saved session
        if let sessionData = UserDefaults.standard.data(forKey: "supabase_session"),
           let _ = try? JSONDecoder().decode(Session.self, from: sessionData) {
            print("📱 Found saved session")
            isLoggedIn = true
            
            // Check username first
            if username.isEmpty {
                print("📱 No username set, showing username screen")
                currentScreen = .username
            } else if !hasPermissions {
                print("📱 Missing permissions, showing permission screen")
                currentScreen = .permissions
            } else {
                print("📱 All set, showing main screen")
                currentScreen = .main
            }
        } else {
            print("📱 No saved session found, showing login screen")
            isLoggedIn = false
            currentScreen = .login
        }
    }
    
    @MainActor
    func setLoggedIn(_ value: Bool) async {
        print("📱 Setting logged in state to:", value)
        isLoggedIn = value
        UserDefaults.standard.set(value, forKey: "isLoggedIn")
        
        if !value {
            // Logout
            print("📱 Logged out, showing login screen")
            username = ""
            UserDefaults.standard.removeObject(forKey: "username")
            currentScreen = .login
            return
        }
        
        // Login flow
        if username.isEmpty {
            print("📱 No username set, showing username screen")
            currentScreen = .username
        } else {
            await checkPermissionStates()
            if !hasPermissions {
                print("📱 Missing permissions, showing permission screen")
                currentScreen = .permissions
            } else {
                print("📱 All set, showing main screen")
                currentScreen = .main
            }
        }
    }
    
    @MainActor
    func setUsername(_ value: String) async {
        print("📱 Setting username to:", value)
        username = value
        UserDefaults.standard.set(value, forKey: "username")
        
        // After setting username, check permissions
        await checkPermissionStates()
        if !hasPermissions {
            print("📱 Missing permissions, showing permission screen")
            currentScreen = .permissions
        } else {
            print("📱 All set, showing main screen")
            currentScreen = .main
        }
    }
    
    func moveToNextScreen() {
        switch currentScreen {
        case .login:
            // Handled by setLoggedIn
            break
        case .username:
            // Handled by setUsername
            break
        case .notifications:
            print("📱 Moving to contacts screen")
            currentScreen = .contacts
        case .contacts, .permissions:
            Task {
                await checkPermissionStates()
                if !hasPermissions {
                    print("📱 Still missing permissions, staying on permission screen")
                    currentScreen = .permissions
                } else {
                    print("📱 All permissions granted, moving to main")
                    currentScreen = .main
                }
            }
        case .main, .complete:
            break
        }
    }
    
    @MainActor
    func checkPermissionStates() async {
        print("📱 Checking permission states...")
        await permissionManager.checkCurrentStatus()
        hasPermissions = permissionManager.hasNotifications && permissionManager.hasContacts
    }
    
    @MainActor
    func signOut() async throws {
        print("📱 Signing out...")
        do {
            try await SupabaseManager.shared.signOut()
            await setLoggedIn(false)
            print("✅ Sign out successful")
        } catch {
            print("❌ Sign out failed:", error)
            throw error
        }
    }
}
