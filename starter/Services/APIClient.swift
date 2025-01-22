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
    
    func sendFriendRequest(toUserId: String) async throws {
        let url = URL(string: "\(baseURL)/friends/request/\(toUserId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(try await getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getPendingFriendRequests() async throws -> [FriendRequest] {
        print("📱 Fetching pending friend requests...")
        let url = URL(string: "\(baseURL)/friends/requests/pending")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(try await getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response while fetching friend requests")
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Bad server response: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        // Debug: Print the response data
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📝 Raw API Response: \(jsonString)")
        }
        
        do {
            let requests = try JSONDecoder().decode([FriendRequest].self, from: data)
            print("✅ Successfully fetched \(requests.count) friend requests")
            return requests
        } catch {
            print("❌ Failed to decode friend requests: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key: \(key) at path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: expected \(type) at path: \(context.codingPath)")
                default:
                    print("Other decoding error: \(decodingError)")
                }
            }
            throw error
        }
    }
    
    func respondToFriendRequest(requestId: String, accept: Bool) async throws {
        print("📱 Responding to friend request \(requestId) with accept=\(accept)")
        let url = URL(string: "\(baseURL)/friends/request/\(requestId)/respond")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(try await getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        let body = ["accept": accept]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Bad server response: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Error details: \(errorString)")
            }
            throw URLError(.badServerResponse)
        }
        
        print("✅ Successfully \(accept ? "accepted" : "rejected") friend request")
    }
    
    /// Fetches the authenticated user's friends list from the API
    /// - Returns: Array of Friendship objects
    /// - Throws: URLError for network issues, DecodingError for parsing issues
    func getFriends() async throws -> [Friendship] {
        let endpoint = "\(baseURL)/friends"
        print("📱 Fetching friends from \(endpoint)")
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(try await getAuthHeader(), forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response type")
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Bad server response: \(httpResponse.statusCode)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error details: \(errorString)")
                }
                throw URLError(.badServerResponse)
            }
            
            #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📱 Raw API Response: \(jsonString)")
            }
            #endif
            
            let friends = try JSONDecoder().decode([Friendship].self, from: data)
            print("✅ Successfully fetched \(friends.count) friends")
            
            #if DEBUG
            for friend in friends {
                print("  - Friend ID: \(friend.id)")
                print("    Username: \(friend.friend?.username ?? "nil")")
            }
            #endif
            
            return friends
            
        } catch let decodingError as DecodingError {
            print("❌ Failed to decode friends: \(decodingError)")
            throw decodingError
        } catch {
            print("❌ Network error: \(error)")
            throw error
        }
    }
}
