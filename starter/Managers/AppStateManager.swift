//
//  AppStateManager.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI
import UserNotifications
import Contacts

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
    
    @Published private(set) var currentScreen: AppScreen = .login
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var username: String = ""
    
    private let permissionManager = PermissionManager.shared
    
    var hasNotifications: Bool { permissionManager.hasNotifications }
    var hasContacts: Bool { permissionManager.hasContacts }
    var hasPermissions: Bool { hasNotifications && hasContacts }
    
    private init() {
        print("📱 Initializing AppStateManager...")
        // Load saved state
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        
        // Try to restore session state
        if let screenRaw = UserDefaults.standard.string(forKey: "currentScreen"),
           let screen = AppScreen(rawValue: screenRaw) {
            self.currentScreen = screen
        }
        
        // Check permissions on launch
        Task {
            await checkPermissionStates()
            
            // Check if we have a saved session
            if UserDefaults.standard.data(forKey: "supabase_session") != nil {
                print("📱 Found saved session, setting logged in state")
                self.isLoggedIn = true
                
                // Set screen based on permissions
                if !hasPermissions {
                    print("📱 Missing permissions, showing permission screen")
                    self.currentScreen = .permissions
                } else if self.currentScreen == .login {
                    print("📱 Has permissions, showing main screen")
                    self.currentScreen = .main
                }
            } else {
                print("📱 No saved session found, setting logged out state")
                self.isLoggedIn = false
                self.currentScreen = .login
            }
        }
    }
    
    func moveToNextScreen() {
        switch currentScreen {
        case .login:
            Task {
                await checkUserStateAndNavigate()
            }
        case .username:
            currentScreen = hasPermissions ? .main : (hasNotifications ? .contacts : .notifications)
        case .notifications:
            currentScreen = .contacts
        case .contacts, .permissions:
            currentScreen = .main
        case .main, .complete:
            break
        }
        
        // Save state
        UserDefaults.standard.set(currentScreen.rawValue, forKey: "currentScreen")
    }
    
    private func checkUserStateAndNavigate() async {
        guard let userId = SupabaseManager.shared.session?.user.id else { return }
        
        do {
            let profile = try await APIClient.shared.fetchProfile(userId: userId.uuidString)
            if let username = profile.username {
                await updateUsername(username)
                currentScreen = hasPermissions ? .main : (hasNotifications ? .contacts : .notifications)
            } else {
                currentScreen = .username
            }
        } catch {
            currentScreen = .username
        }
    }
    
    func signOut() async throws {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            await updateLoginState(false)
            await updateUsername("")
            currentScreen = .login
            UserDefaults.standard.set(AppScreen.login.rawValue, forKey: "currentScreen")
        } catch {
            throw error
        }
    }
    
    func setLoggedIn(_ value: Bool) {
        print("📱 Setting logged in state to: \(value)")
        isLoggedIn = value
        UserDefaults.standard.set(value, forKey: "isLoggedIn")
        
        if value {
            if currentScreen == .login {
                if !hasPermissions {
                    print("📱 Missing permissions, showing permission screen")
                    currentScreen = .permissions
                } else {
                    print("📱 Has permissions, showing main screen")
                    currentScreen = .main
                }
            }
        } else {
            currentScreen = .login
            username = ""
            UserDefaults.standard.removeObject(forKey: "username")
        }
        
        // Save current screen
        UserDefaults.standard.set(currentScreen.rawValue, forKey: "currentScreen")
    }
    
    func setUsername(_ value: String) {
        Task { @MainActor in
            await updateUsername(value)
        }
    }
    
    private func updateLoginState(_ value: Bool) async {
        isLoggedIn = value
        UserDefaults.standard.set(value, forKey: "isLoggedIn")
    }
    
    private func updateUsername(_ value: String) async {
        username = value
        UserDefaults.standard.set(value, forKey: "username")
    }
    
    func checkPermissions() async -> Bool {
        await checkPermissionStates()
        return hasPermissions
    }
    
    func checkPermissionStates() async {
        print("📱 Checking permission states...")
        await permissionManager.checkPermissionStates()
        
        // Update screen if needed
        if isLoggedIn && !hasPermissions && currentScreen == .main {
            print("📱 Missing permissions detected, moving to permissions screen")
            currentScreen = .permissions
        }
    }
}
