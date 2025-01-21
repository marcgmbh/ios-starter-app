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
    @Published var session: AuthResponse?
    
    private init() {
        setupClient()
    }
    
    private func setupClient() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://yomfeglcepedevkbcyup.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvbWZlZ2xjZXBlZGV2a2JjeXVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcwNTMzNDksImV4cCI6MjA1MjYyOTM0OX0.ITq5zpKbFv6uTBpNmkL33wu5FQcChnfu7eJQ_qdWGmo"
        )
        
        // Try to restore session
        if let data = UserDefaults.standard.data(forKey: "supabase_session"),
           let session = try? JSONDecoder().decode(AuthResponse.self, from: data) {
            self.session = session
            AppStateManager.shared.setLoggedIn(true)
        }
    }
    
    func signInWithPhone(phoneNumber: String) async throws {
        try await client.auth.signInWithOTP(
            phone: phoneNumber,
            shouldCreateUser: true
        )
    }
    
    func verifyOTP(phoneNumber: String, code: String) async throws {
        let result = try await client.auth.verifyOTP(
            phone: phoneNumber,
            token: code,
            type: .sms
        )
        session = result
        
        // Save session
        if let data = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(data, forKey: "supabase_session")
        }
    }
}
