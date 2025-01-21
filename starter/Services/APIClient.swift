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
    
    func fetchProfile(userId: String) async throws -> Profile {
        let url = URL(string: "\(baseURL)/users/\(userId)/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Profile.self, from: data)
    }
    
    func updateProfile(userId: String, username: String) async throws -> Profile {
        let url = URL(string: "\(baseURL)/users/\(userId)/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("📱 Updating profile:")
        print("   URL: \(url)")
        print("   Username: \(username)")
        print("   User ID: \(userId)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Debug response
        if let responseString = String(data: data, encoding: .utf8) {
            print("📱 Response:")
            print("   Status Code: \(httpResponse.statusCode)")
            print("   Body: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(Profile.self, from: data)
        } catch {
            print("❌ Decoding error: \(error)")
            throw error
        }
    }
}
