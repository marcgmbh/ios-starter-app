//
//  FriendRequestRowView.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI

struct FriendRequestRowView: View {
    let request: FriendRequest
    @StateObject private var viewModel = FriendRequestViewModel()
    
    var body: some View {
        HStack {
            if let pfpUrl = request.fromUser?.pfpUrl {
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
                Text(request.fromUser?.username ?? "Unknown")
                    .font(.headline)
            }
            
            Spacer()
            
            if request.status == .pending {
                HStack(spacing: 12) {
                    Button {
                        Task {
                            await viewModel.acceptRequest(request)
                        }
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Button {
                        Task {
                            await viewModel.rejectRequest(request)
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}
