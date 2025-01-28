//
//  DescriptionText.swift
//  starter
//
//  Created by marc on 21.01.25.
//

import SwiftUI

struct DescriptionText: View {
    // MARK: - Properties
    
    let text: String
    let style: TextStyle
    let alignment: TextAlignment
    
    // MARK: - Types
    
    enum TextStyle {
        case title
        case description
        case subtitle
        
        var font: Font {
            switch self {
            case .title:
                return .system(size: 35, weight: .black, design: .rounded)
            case .description:
                return .system(size: 20, weight: .regular, design: .rounded)
            case .subtitle:
                return .system(size: 18, weight: .regular, design: .rounded)
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .title:
                return .primary
            case .description, .subtitle:
                return .gray
            }
        }
    }
    
    // MARK: - Initialization
    
    init(
        _ text: String,
        style: TextStyle = .description,
        alignment: TextAlignment = .center
    ) {
        self.text = text
        self.style = style
        self.alignment = alignment
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(text)
            .multilineTextAlignment(alignment)
            .font(style.font)
            .foregroundStyle(style.foregroundColor)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        DescriptionText("Welcome Back!", style: .title)
        DescriptionText("Please enter your details to continue", style: .description)
        DescriptionText("By continuing, you agree to our Terms", style: .subtitle)
            .padding(.horizontal)
    }
}
