//
//  SupabaseManager.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import Foundation
import Supabase

@MainActor
final class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    var client: SupabaseClient!
    @Published var session: Session?
    
    private init() {
        print("🔐 Initializing SupabaseManager...")
        setupClient()
    }
    
    private func setupClient() {
        print("🔐 Setting up Supabase client...")
        
        client = SupabaseClient(
            supabaseURL: URL(string: "https://yomfeglcepedevkbcyup.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvbWZlZ2xjZXBlZGV2a2JjeXVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcwNTMzNDksImV4cCI6MjA1MjYyOTM0OX0.ITq5zpKbFv6uTBpNmkL33wu5FQcChnfu7eJQ_qdWGmo"
        )
        
        // Try to restore session
        if let data = UserDefaults.standard.data(forKey: "supabase_session") {
            print("🔐 Found saved session data")
            
            do {
                let session = try JSONDecoder().decode(Session.self, from: data)
                print("🔐 Successfully decoded session")
                
                // Try to refresh the session using the refresh token
                Task {
                    do {
                        let refreshToken = session.refreshToken
                        let newSession = try await client.auth.refreshSession(refreshToken: refreshToken)
                        print("✅ Successfully refreshed session")
                        self.session = newSession
                        
                        // Save the new session
                        if let data = try? JSONEncoder().encode(newSession) {
                            UserDefaults.standard.set(data, forKey: "supabase_session")
                            print("💾 Saved refreshed session to UserDefaults")
                        }
                        await AppStateManager.shared.setLoggedIn(true)
                        
                        // Update FCM token since we're now logged in
                        NotificationManager.shared.fetchAndUpdateFCMToken()
                    } catch {
                        print("❌ Failed to refresh session:", error)
                        UserDefaults.standard.removeObject(forKey: "supabase_session")
                        await AppStateManager.shared.setLoggedIn(false)
                    }
                }
            } catch {
                print("❌ Failed to decode session:", error)
                UserDefaults.standard.removeObject(forKey: "supabase_session")
            }
        } else {
            print("❌ No saved session found")
        }
    }
    
    private func refreshSessionIfNeeded() async {
        print("🔄 Refreshing session...")
        do {
            if let currentSession = session {
                let newSession = try await client.auth.refreshSession(refreshToken: currentSession.refreshToken)
                print("✅ Session refresh successful for user: \(newSession.user.id)")
                self.session = newSession
                
                // Save refreshed session
                if let data = try? JSONEncoder().encode(newSession) {
                    UserDefaults.standard.set(data, forKey: "supabase_session")
                    print("💾 Saved refreshed session to UserDefaults")
                }
                await AppStateManager.shared.setLoggedIn(true)
            }
        } catch {
            print("❌ Failed to refresh session: \(error)")
            // Clear invalid session
            UserDefaults.standard.removeObject(forKey: "supabase_session")
            self.session = nil
            await AppStateManager.shared.setLoggedIn(false)
        }
    }
    
    func signInWithPhone(phoneNumber: String) async throws {
        print("📱 Signing in with phone...")
        try await client.auth.signInWithOTP(
            phone: phoneNumber,
            shouldCreateUser: true
        )
    }
    
    func verifyOTP(phoneNumber: String, code: String) async throws {
        print("🔐 Verifying OTP...")
        let result = try await client.auth.verifyOTP(
            phone: phoneNumber,
            token: code,
            type: .sms
        )
        
        if let session = result.session {
            print("✅ OTP verification successful")
            self.session = session
            
            // Save session
            if let data = try? JSONEncoder().encode(session) {
                UserDefaults.standard.set(data, forKey: "supabase_session")
                print("💾 Saved new session to UserDefaults")
            }
            
            // First set logged in state
            await AppStateManager.shared.setLoggedIn(true)
            
            // Then check if user has username
            do {
                let profile = try await APIClient.shared.fetchProfile(userId: session.user.id.uuidString)
                if let username = profile.username {
                    print("📱 Found username:", username)
                    await AppStateManager.shared.setUsername(username)
                }
            } catch {
                print("❌ Error fetching profile:", error)
            }
        } else {
            print("❌ No session returned from OTP verification")
            throw NSError(domain: "SupabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No session returned"])
        }
    }
    
    func signOut() async throws {
        print("🔐 Signing out...")
        do {
            try await client.auth.signOut()
            UserDefaults.standard.removeObject(forKey: "supabase_session")
            session = nil
            await AppStateManager.shared.setLoggedIn(false)
            print("✅ Sign out successful")
        } catch {
            print("❌ Error signing out:", error)
            throw error
        }
    }
    
    func saveFCMToken(_ token: String) async throws {
        print("📱 Starting FCM token save process...")
        
        guard let session = session else {
            print("❌ FCM token save failed: No active session")
            throw NSError(domain: "SupabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No active session"])
        }
        
        let userId = session.user.id.uuidString
        print("📱 Saving FCM token for user:", userId)
        
        do {
            try await client.database
                .from("profiles")
                .update(["fcm_token": token])
                .eq("user_id", value: userId)
                .execute()
            print("✅ Successfully saved FCM token to profiles table")
        } catch {
            print("❌ Failed to save FCM token:", error)
            throw error
        }
    }
}
