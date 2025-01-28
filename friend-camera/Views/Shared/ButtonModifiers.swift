import SwiftUI

struct ActionButtonStyle: ViewModifier {
    let backgroundColor: Color
    let foregroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
    }
}

extension View {
    func actionButtonStyle(backgroundColor: Color, foregroundColor: Color = .white) -> some View {
        modifier(ActionButtonStyle(backgroundColor: backgroundColor, foregroundColor: foregroundColor))
    }
    
    func primaryActionStyle() -> some View {
        actionButtonStyle(backgroundColor: Color(hex: "F03889"))
    }
    
    func secondaryActionStyle() -> some View {
        actionButtonStyle(backgroundColor: Color.gray.opacity(0.15), foregroundColor: .black)
    }
}
