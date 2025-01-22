//
//  FriendsModel.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import Foundation

enum FriendRequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case canceled = "canceled"
}

enum FriendRequestDirection: String, Codable {
    case sent
    case received
}

/// Represents a user profile in the system
struct Profile: Codable, Identifiable, Equatable {
    // MARK: - Properties
    let id: String
    var username: String?
    var phone_number: String?
    var pfpUrl: String?
    var createdAt: String?  
    var updatedAt: String? 
    
    // MARK: - Coding Keys
    /// Primary coding keys using user_id (for friend requests)
    private enum CodingKeys: String, CodingKey {
        case id = "user_id"
    }
    
    /// Alternative coding keys using id (for friend list)
    private enum CustomCodingKeys: String, CodingKey {
        case id
        case username
        case phone_number
        case pfpUrl = "pfp_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Initialization
    /// Custom decoder that handles both user_id and id fields
    /// - Parameter decoder: The decoder to read from
    /// - Throws: DecodingError if required fields are missing or invalid
    init(from decoder: Decoder) throws {
        // Try to decode as user_id first, fall back to id if that fails
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
        } catch {
            let container = try decoder.container(keyedBy: CustomCodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
        }
        
        // Decode optional fields
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        phone_number = try container.decodeIfPresent(String.self, forKey: .phone_number)
        pfpUrl = try container.decodeIfPresent(String.self, forKey: .pfpUrl)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.id == rhs.id
    }
}

struct FriendRequest: Codable, Identifiable, Equatable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let status: FriendRequestStatus
    let createdAt: String
    let updatedAt: String
    var fromUser: Profile?
    var toUser: Profile?
    var direction: FriendRequestDirection?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fromUser = "from_user"
        case toUser = "to_user"
        case direction
    }
    
    // Computed property to determine if request should be shown in grey
    var isPendingSent: Bool {
        return status == .pending && direction == .sent
    }
    
    static func == (lhs: FriendRequest, rhs: FriendRequest) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Friendship: Codable, Identifiable, Equatable {
    let id: String
    let user1Id: String
    let user2Id: String
    let createdAt: String
    var friend: Profile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user1Id = "user1_id"
        case user2Id = "user2_id"
        case createdAt = "created_at"
        case friend
    }
    
    static func == (lhs: Friendship, rhs: Friendship) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Contact: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let phoneNumber: String
    let username: String?
    
    init(id: String, name: String, phoneNumber: String, username: String? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.username = username
    }
    
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ContactMatch: Codable {
    let id: String
    let phoneNumber: String
}
