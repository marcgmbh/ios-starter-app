import SwiftUI

struct BottomButtonLayout<Content: View, ButtonContent: View>: View {
    let content: Content
    let buttonContent: ButtonContent
    let horizontalPadding: CGFloat
    @FocusState private var isFocused: Bool
    
    init(
        horizontalPadding: CGFloat = 24,
        @ViewBuilder content: () -> Content,
        @ViewBuilder buttonContent: () -> ButtonContent
    ) {
        self.content = content()
        self.buttonContent = buttonContent()
        self.horizontalPadding = horizontalPadding
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }
            
            VStack {
                Spacer()
                
                content
                    .padding(.horizontal, horizontalPadding)
                
                Spacer()
                
                buttonContent
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}

private struct FocusStateKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isFocused: Bool {
        get { self[FocusStateKey.self] }
        set { self[FocusStateKey.self] = newValue }
    }
}

// Preview provider for BottomButtonLayout
struct BottomButtonLayout_Previews: PreviewProvider {
    static var previews: some View {
        BottomButtonLayout {
            Text("Content")
        } buttonContent: {
            Button("Action") {}
        }
    }
}
