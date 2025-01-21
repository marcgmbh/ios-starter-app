//
//  FriendRowView.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI

struct FriendRowView: View {
    let friendship: Friendship
    
    var friendProfile: Profile? {
        // Get the other user's profile
        friendship.user1 ?? friendship.user2
    }
    
    var body: some View {
        HStack {
            if let pfpUrl = friendProfile?.pfpUrl {
                AsyncImage(url: URL(string: pfpUrl)) { image in
                    image.resizable()
                } placeholder: {
                    Circle()
                        .foregroundColor(.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading) {
                Text(friendProfile?.username ?? "Unknown")
                    .font(.headline)
            }
            
            Spacer()
            
            Menu {
                Button(role: .destructive) {
                    // Handle unfriend
                } label: {
                    Label("Unfriend", systemImage: "person.badge.minus")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
    }
}
