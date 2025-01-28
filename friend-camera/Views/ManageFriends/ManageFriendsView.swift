//
//  ManageFriendsView.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI
import Contacts

struct ManageFriendsView: View {
    @StateObject private var viewModel: ManageFriendsViewModel
    @State private var showContactsPermissionAlert = false
    @State private var showShareSheet = false
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ManageFriendsViewModel = ManageFriendsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    // Friends Section
                    Section {
                        if viewModel.isLoadingFriends {
                            ProgressView()
                                .accessibilityLabel("Loading friends")
                                .listRowStyle()
                        } else if viewModel.friendships.isEmpty {
                            Text("No friends yet")
                                .foregroundColor(.gray)
                                .listRowStyle()
                        } else {
                            ForEach(viewModel.friendships) { friendship in
                                FriendRowView(friendship: friendship)
                                    .listRowStyle()
                                    .transition(.opacity)
                            }
                            .animation(.easeOut(duration: 0.2), value: viewModel.friendships)
                        }
                    } header: {
                        Text("Friends")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .textCase(nil)
                    }
                    
                    // Friend Requests Section
                    Section {
                        if viewModel.isLoadingRequests {
                            ProgressView()
                                .accessibilityLabel("Loading friend requests")
                                .listRowStyle()
                        } else if viewModel.friendRequests.isEmpty {
                            Text("No pending requests")
                                .foregroundColor(.gray)
                                .listRowStyle()
                        } else {
                            ForEach(viewModel.friendRequests) { request in
                                FriendRequestRowView(request: request)
                                    .listRowStyle()
                                    .transition(.opacity)
                            }
                            .animation(.easeOut(duration: 0.2), value: viewModel.friendRequests)
                        }
                    } header: {
                        Text("Friend Requests")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .textCase(nil)
                    }
                    
                    // Add Friends Section (formerly Contacts)
                    Section {
                        if viewModel.contacts.isEmpty {
                            Text("Invite friends and they'll appear here.")
                                .foregroundColor(.gray)
                                .listRowStyle()
                        } else {
                            ForEach(viewModel.contacts) { contact in
                                ContactRowView(contact: contact)
                                    .listRowStyle()
                                    .transition(.opacity)
                            }
                            .animation(.easeOut(duration: 0.2), value: viewModel.contacts)
                        }
                    } header: {
                        Text("Add Friends")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .textCase(nil)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .refreshable {
                    await viewModel.refresh()
                }
                .task {
                    await requestContactsPermission()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 17 , weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                // Floating Share Button
                VStack {
                    Spacer()
                    Button {
                        showShareSheet = true
                    } label: {
                        PrimaryButton(text: "Share with Friends")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .sheet(isPresented: $showShareSheet) {
                    let appURL = URL(string: "https://example.com/app")! // Replace with your app's URL
                    ShareSheet(activityItems: [
                        "Join me on this awesome app!",
                        appURL
                    ])
                }
            }
            .alert("Contacts Access Required", isPresented: $showContactsPermissionAlert) {
                Button("Open Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                .accessibilityHint("Opens system settings to enable contacts access")
                
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
            showContactsPermissionAlert = true
        }
    }
}

struct ListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
}

extension View {
    func listRowStyle() -> some View {
        modifier(ListRowModifier())
    }
}

// ShareSheet UIViewControllerRepresentable
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct ManageFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageFriendsView()
    }
}
