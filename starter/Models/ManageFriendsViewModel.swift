import Foundation
import Contacts

@MainActor
class ManageFriendsViewModel: ObservableObject {
    @Published var friendships: [Friendship] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var contacts: [Contact] = []
    private let contactStore = CNContactStore()
    
    func refresh() async {
        await loadContacts()
        // TODO: Load friendships and friend requests
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
                    phoneNumber: "" // We don't need to display the phone number
                )
            }
            
            // Update UI on main thread
            self.contacts = matchedContacts.sorted { $0.name < $1.name }
            
        } catch {
            print("Error loading contacts: \(error)")
        }
    }
}

@MainActor
class FriendRequestViewModel: ObservableObject {
    func acceptRequest(_ request: FriendRequest) async {
        // TODO: Implement accept friend request logic
    }
    
    func rejectRequest(_ request: FriendRequest) async {
        // TODO: Implement reject friend request logic
    }
}

@MainActor
class ContactViewModel: ObservableObject {
    func sendFriendRequest(to contact: Contact) async {
        // TODO: Implement send friend request logic
    }
}
