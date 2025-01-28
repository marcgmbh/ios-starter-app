//
//  EmptyStateView.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.black)
            
            if !description.isEmpty {
                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
