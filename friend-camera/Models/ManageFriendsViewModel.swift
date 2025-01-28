//
//  ManageFriendsViewModel.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import Foundation
import Contacts

@MainActor
class ManageFriendsViewModel: ObservableObject {
    @Published var friendships: [Friendship] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var contacts: [Contact] = []
    @Published var isLoadingRequests = false
    @Published var isLoadingFriends = false
    @Published var friendRequestsError: Error?
    @Published var friendsError: Error?
    private let contactStore = CNContactStore()
    
    nonisolated init() {
        print("📱 ManageFriendsViewModel initialized")
        Task { @MainActor in
            self.setupNotifications()
        }
    }
    
    @MainActor
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFriendRequestSent),
            name: NSNotification.Name("FriendRequestSent"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFriendRequestUpdate),
            name: NSNotification.Name("FriendRequestUpdate"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleFriendRequestSent(_ notification: Notification) {
        if let contactId = notification.userInfo?["contactId"] as? String {
            // Remove the contact and refresh friend requests
            removeContact(withId: contactId)
            Task {
                await refresh()
            }
        }
    }
    
    @objc private func handleFriendRequestUpdate() {
        Task { @MainActor in
            await refresh()
        }
    }
    
    func removeContact(withId id: String) {
        contacts.removeAll { $0.id == id }
    }
    
    func refresh() async {
        print("📱 Refreshing ManageFriendsView data...")
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadFriends() }
            group.addTask { await self.loadPendingRequests() }
            group.addTask { await self.loadContacts() }
        }
    }
    
    private func normalizePhoneNumber(_ phoneNumber: String) -> String {
        phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
    
    private func loadContacts() async {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            // Move contact loading off main thread
            let phoneNumbers = try await Task.detached {
                var numbers = Set<String>()
                try await withCheckedThrowingContinuation { continuation in
                    do {
                        try CNContactStore().enumerateContacts(with: request) { contact, _ in
                            for phoneNumber in contact.phoneNumbers {
                                let number = phoneNumber.value.stringValue
                                numbers.insert(self.normalizePhoneNumber(number))
                            }
                        }
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                return Array(numbers)
            }.value
            
            // Then, find matches from the server
            let matches = try await ContactService.shared.matchContacts(phoneNumbers: phoneNumbers)
            
            // Create contacts from matches
            let matchedContacts = matches.map { match in
                Contact(
                    id: match.id,
                    name: match.username,
                    phoneNumber: ""
                )
            }
            
            // Update UI on main thread
            self.contacts = matchedContacts.sorted { $0.name < $1.name }
            
        } catch {
            // Clear contacts on error
            self.contacts = []
        }
    }
    
    private func loadPendingRequests() async {
        isLoadingRequests = true
        friendRequestsError = nil
        
        do {
            self.friendRequests = try await APIClient.shared.getPendingFriendRequests()
        } catch {
            print("❌ Error in ViewModel - Failed to load friend requests: \(error)")
            self.friendRequestsError = error
            self.friendRequests = []
        }
        
        isLoadingRequests = false
    }
    
    private func loadFriends() async {
        print("📱 Loading friends...")
        isLoadingFriends = true
        do {
            friendships = try await APIClient.shared.getFriends()
            print("✅ Loaded \(friendships.count) friends")
        } catch {
            print("❌ Failed to load friends: \(error)")
            friendsError = error
        }
        isLoadingFriends = false
    }
}

@MainActor
class FriendRequestViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    
    func acceptRequest(_ request: FriendRequest) async {
        isLoading = true
        error = nil
        
        do {
            print("✅ Accepting friend request: \(request.id)")
            try await APIClient.shared.respondToFriendRequest(requestId: request.id, accept: true)
            NotificationCenter.default.post(name: NSNotification.Name("FriendRequestUpdate"), object: nil)
            print("✅ Friend request accepted successfully")
        } catch {
            print("❌ Failed to accept friend request: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    func rejectRequest(_ request: FriendRequest) async {
        isLoading = true
        error = nil
        
        do {
            print("✅ Rejecting friend request: \(request.id)")
            try await APIClient.shared.respondToFriendRequest(requestId: request.id, accept: false)
            NotificationCenter.default.post(name: NSNotification.Name("FriendRequestUpdate"), object: nil)
            print("✅ Friend request rejected successfully")
        } catch {
            print("❌ Failed to reject friend request: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
}

@MainActor
class ContactViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    
    func sendFriendRequest(to contact: Contact) async {
        isLoading = true
        error = nil
        
        do {
            try await APIClient.shared.sendFriendRequest(toUserId: contact.id)
            
            // Post notification to update UI
            NotificationCenter.default.post(
                name: NSNotification.Name("FriendRequestSent"),
                object: nil,
                userInfo: ["contactId": contact.id]
            )
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
