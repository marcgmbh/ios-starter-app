//
//  ContactService.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import Foundation

class ContactService {
    static let shared = ContactService()
    private let apiClient = APIClient.shared
    private let batchSize = 100
    
    private init() {}
    
    func matchContacts(phoneNumbers: [String]) async throws -> [APIClient.ContactMatch] {
        var allMatches: [APIClient.ContactMatch] = []
        
        for i in stride(from: 0, to: phoneNumbers.count, by: batchSize) {
            let end = min(i + batchSize, phoneNumbers.count)
            let batch = Array(phoneNumbers[i..<end])
            let batchMatches = try await apiClient.matchContacts(phoneNumbers: batch)
            allMatches.append(contentsOf: batchMatches)
        }
        
        return allMatches
    }
}
