import SwiftUI


struct InputFieldView: View {
    // MARK: - Properties
    
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let onChange: ((String) -> Void)?
    
    @FocusState private var isFocused: Bool
    
    // MARK: - Constants
    
    private enum Constants {
        static let fontSize: CGFloat = 30
        static let verticalPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 30
        static let horizontalPadding: CGFloat = 16
    }
    
    // MARK: - Initialization
    
    init(
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        onChange: ((String) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.onChange = onChange
    }
    
    // MARK: - Body
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.horizontal, Constants.horizontalPadding)
            .multilineTextAlignment(.center)
            .font(.system(
                size: Constants.fontSize,
                weight: .regular,
                design: .rounded
            ))
            .padding(.vertical, Constants.verticalPadding)
            .frame(minWidth: 100, maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(Constants.cornerRadius)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .focused($isFocused)
            .onChange(of: text) { oldValue, newValue in
                onChange?(newValue)
            }
    }
    
    // MARK: - Private Views
    
    private var backgroundColor: Color {
        Color(uiColor: .systemBackground)
    }
}
