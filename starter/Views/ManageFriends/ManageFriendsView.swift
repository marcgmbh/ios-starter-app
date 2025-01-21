//
//  ManageFriendsView.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI
import Contacts

struct ManageFriendsView: View {
    @StateObject private var viewModel = ManageFriendsViewModel()
    @State private var showContactsPermissionAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Friends Section
                Section(header: Text("Friends")) {
                    if viewModel.friendships.isEmpty {
                        Text("No friends yet")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.friendships) { friendship in
                            FriendRowView(friendship: friendship)
                        }
                    }
                }
                
                // Friend Requests Section
                Section(header: Text("Friend Requests")) {
                    if viewModel.friendRequests.isEmpty {
                        Text("No pending requests")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.friendRequests) { request in
                            FriendRequestRowView(request: request)
                        }
                    }
                }
                
                // Contacts Section
                Section(header: Text("Contacts")) {
                    if viewModel.contacts.isEmpty {
                        Text("No contacts found")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.contacts) { contact in
                            ContactRowView(contact: contact)
                        }
                    }
                }
            }
            .navigationTitle("Manage Friends")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await requestContactsPermission()
            }
            .alert("Contacts Access Required", isPresented: $showContactsPermissionAlert) {
                Button("Open Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow access to your contacts to find friends using the app.")
            }
        }
    }
    
    private func requestContactsPermission() async {
        let store = CNContactStore()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .notDetermined:
            do {
                let granted = try await store.requestAccess(for: .contacts)
                if granted {
                    await viewModel.refresh()
                } else {
                    showContactsPermissionAlert = true
                }
            } catch {
                showContactsPermissionAlert = true
            }
        case .authorized:
            await viewModel.refresh()
        case .denied, .restricted:
            showContactsPermissionAlert = true
        @unknown default:
            break
        }
    }
}

// MARK: - Preview
struct ManageFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageFriendsView()
    }
}
