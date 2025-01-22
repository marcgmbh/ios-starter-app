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
    @State private var isProcessing = false
    @State private var opacity = 1.0
    
    var body: some View {
        HStack(spacing: 12) {
            // Username
            Text(request.direction == .sent ? 
                 "\(request.toUser?.username ?? "Unknown")" :
                 "\(request.fromUser?.username ?? "Unknown")")
                .font(.system(size: 15, weight: .medium))
                .lineLimit(1)
            
            Spacer()
            
            // Action Buttons
            if request.status == .pending {
                if request.direction == .received {
                    HStack(spacing: 8) {
                        Button {
                            guard !isProcessing else { return }
                            isProcessing = true
                            withAnimation(.easeOut(duration: 0.2)) {
                                opacity = 0
                            }
                            Task {
                                print("📱 Accepting friend request")
                                await viewModel.acceptRequest(request)
                                isProcessing = false
                            }
                        } label: {
                            Text("yes")
                                .primaryActionStyle()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(isProcessing)
                        
                        Button {
                            guard !isProcessing else { return }
                            isProcessing = true
                            withAnimation(.easeOut(duration: 0.2)) {
                                opacity = 0
                            }
                            Task {
                                print("📱 Rejecting friend request")
                                await viewModel.rejectRequest(request)
                                isProcessing = false
                            }
                        } label: {
                            Text("no")
                                .secondaryActionStyle()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(isProcessing)
                    }
                } else {
                    Text("Pending")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(opacity)
        .contentShape(Rectangle())
    }
}
