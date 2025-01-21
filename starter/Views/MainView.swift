//
//  MainView.swift
//  starter
//
//  Created by marc on 16.01.25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome \(appState.username)!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You're all set!")
                .font(.title2)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                appState.reset()
            }) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
