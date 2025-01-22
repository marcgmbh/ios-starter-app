//
//  FriendRowView.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI

/// ViewModel for managing friends list state and operations
class FriendsViewModel: ObservableObject {
    @Published var friends: [Friendship] = []
    @Published var error: Error?
    @Published var isLoading = false
    
    /// Fetches the current user's friends list from the API
    func fetchFriends() async {
        isLoading = true
        do {
            friends = try await APIClient.shared.getFriends()
        } catch {
            print("❌ Failed to fetch friends: \(error)")
            self.error = error
        }
        isLoading = false
    }
}

/// A view that displays a single friend in the friends list
struct FriendRowView: View {
    // MARK: - Properties
    let friendship: Friendship
    
    /// The friend's profile to display
    private var friendProfile: Profile? {
        friendship.friend
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(friendProfile?.username ?? "Unknown")")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
// MARK: - Preview
struct FriendRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock data using Codable
        let mockJson = """
        {
            "id": "test-id",
            "user1_id": "user1",
            "user2_id": "user2",
            "created_at": "2025-01-22",
            "friend": {
                "id": "friend-id",
                "username": "testuser"
            }
        }
        """.data(using: .utf8)!
        
        let mockFriendship = try! JSONDecoder().decode(Friendship.self, from: mockJson)
        
        FriendRowView(friendship: mockFriendship)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif

struct FriendsListView: View {
    @StateObject private var viewModel = FriendsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if !viewModel.friends.isEmpty {
                List(viewModel.friends) { friendship in
                    FriendRowView(friendship: friendship)
                }
                .listStyle(.plain)
            } else {
                Text("No friends yet")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await viewModel.fetchFriends()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}
