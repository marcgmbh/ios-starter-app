//
//  ContactRowView.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI

struct ContactRowView: View {
    let contact: Contact
    @StateObject private var viewModel = ContactViewModel()
    @State private var isProcessing = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(contact.name)
                .font(.system(size: 15, weight: .medium))
                .lineLimit(1)
            
            Spacer()
            
            Button {
                guard !isProcessing else { return }
                isProcessing = true
                Task {
                    await viewModel.sendFriendRequest(to: contact)
                    isProcessing = false
                }
            } label: {
                Text("Add")
                    .primaryActionStyle()
            }
            .buttonStyle(BorderlessButtonStyle())
            .disabled(isProcessing)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
