//
//  PrimaryButton.swift
//  starter
//
//  Created by marc on 19.01.25.
//

import SwiftUI

struct PrimaryButton: View {
    let text: String
    var isLoading: Bool = false
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                Text(text)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 25)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(text: "Continue")
        PrimaryButton(text: "Loading", isLoading: true)
    }
    .padding()
}
