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

struct Profile: Codable, Identifiable {
    let id: String
    var username: String?
    var phone_number: String?
    var pfpUrl: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username
        case pfpUrl = "pfp_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct FriendRequest: Codable, Identifiable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let status: FriendRequestStatus
    let createdAt: String
    let updatedAt: String
    var fromUser: Profile?
    var toUser: Profile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromUserId = "from_user_id"
        case toUserId = "to_user_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fromUser = "from_user"
        case toUser = "to_user"
    }
}

struct Friendship: Codable, Identifiable {
    let id: String
    let user1Id: String
    let user2Id: String
    let createdAt: String
    var user1: Profile?
    var user2: Profile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user1Id = "user1_id"
        case user2Id = "user2_id"
        case createdAt = "created_at"
        case user1
        case user2
    }
}

struct Contact: Identifiable {
    let id: String
    let name: String
    let phoneNumber: String
}

struct ContactMatch: Codable {
    let id: String
    let phoneNumber: String
}
