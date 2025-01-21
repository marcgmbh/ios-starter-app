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
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.gray.opacity(0.3))
                .frame(width: 40, height: 40)
            
            Text("@\(contact.name)")
                .font(.headline)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.sendFriendRequest(to: contact)
                }
            } label: {
                Text("Add")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
    
