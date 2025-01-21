//
//  APIClient.swift
//  starter
//
//  Created by marc on 20.01.25.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://ios-starter-api-production.up.railway.app"
    
    private init() {}
    
    struct Profile: Codable {
        let id: String
        let username: String?
        let updatedAt: String
        
        enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case username
            case updatedAt = "updated_at"
        }
    }
    
    struct ContactMatch: Codable {
        let id: String
        let username: String
    }
    
    private func getAuthHeader() async throws -> String {
        let session = try await SupabaseManager.shared.client.auth.session
        return "Bearer \(session.accessToken)"
    }
    
    func fetchProfile(userId: String) async throws -> Profile {
        let url = URL(string: "\(baseURL)/users/me/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(try await getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Profile.self, from: data)
    }
    
    func updateProfile(userId: String, username: String) async throws -> Profile {
        let url = URL(string: "\(baseURL)/users/me/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(try await getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let body = ["username": username]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(Profile.self, from: data)
        } catch {
            throw error
        }
    }
    
    func matchContacts(phoneNumbers: [String]) async throws -> [ContactMatch] {
        let url = URL(string: "\(baseURL)/friends/contacts/match")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(try await getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "phoneNumbers": phoneNumbers
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([ContactMatch].self, from: data)
    }
}
