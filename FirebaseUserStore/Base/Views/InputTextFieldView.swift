import SwiftUI

struct InputTextFieldView: View {
    @Binding var text: String
    private let isSecureField: Bool
    private let placeholder: String
    private let keyboardType: UIKeyboardType
    private let systemImage: String?
    @Binding var errorMessage: String?
    @Binding var isValid: Bool

    @State private var isShowMessage = false
    @State private var isShowCleanButton = false
    @FocusState private var focused: Bool
    private let textFieldLeading: CGFloat = 30

    private let cleanHandler: (() -> ())?
    private let focusHandler: (() -> ())?
    private let unfocusHandler: (() -> ())?
    private let onChangeTextHandler: ((String) -> ())?

    init(
        text: Binding<String>,
        isSecureField: Bool = false,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        systemImage: String? = nil,
        errorMessage: Binding<String?> = .constant(nil),
        isValid: Binding<Bool> = .constant(true),
        cleanHandler: (() -> ())? = nil,
        focusHandler: (() -> ())? = nil,
        unfocusHandler: (() -> ())? = nil,
        onChangeTextHandler: ((String) -> ())? = nil
    ) {
        self._text = text
        self.isSecureField = isSecureField
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.systemImage = systemImage
        self._errorMessage = errorMessage
        self._isValid = isValid
        self.cleanHandler = cleanHandler
        self.focusHandler = focusHandler
        self.unfocusHandler = unfocusHandler
        self.onChangeTextHandler = onChangeTextHandler
    }

    init(
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType,
        systemImage: String?
    ) {
        self._text = text
        self.isSecureField = false
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.systemImage = systemImage
        self._isValid = .constant(true)
        self._errorMessage = .constant(nil)
        self.cleanHandler = nil
        self.focusHandler = nil
        self.unfocusHandler = nil
        self.onChangeTextHandler = nil
    }

    var body: some View {
        VStack {
            if isShowMessage {
                HStack {
                    Text(errorMessage ?? " ")
                        .font(.system(size: 10, design: .monospaced)).bold().foregroundColor(.gray)
                    Spacer()
                }
            }
            textView
        }
        .padding(3)
    }

    @ViewBuilder private var textFieldByStyle: some View {
        if isSecureField {
            SecureField(placeholder, text: $text)
        } else {
            HStack {
                TextField(placeholder, text: $text)
                if isShowCleanButton {
                    Button {
                        withAnimation {
                            text = ""
                            cleanHandler?()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 5)
                }
            }
        }
    }

    private var textView: some View {
        textFieldByStyle
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                   minHeight: 44,
                   alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding(.leading, systemImage == nil ? textFieldLeading / 2 : textFieldLeading)
            .keyboardType(keyboardType)
            .background(
                ZStack(alignment: .leading) {
                    if let systemImage = systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading, 5)
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    RoundedRectangle(cornerRadius: 10,
                                     style: .continuous)
                    .stroke(isValid ? Color.gray.opacity(0.25) : Color.red, lineWidth: 1)
                }
            )
            .onTapGesture {
                withAnimation(.easeIn(duration: 1)) {
                    isValid = true
                }
            }
            .onChange(of: isValid, perform: { isValid in
                focused = isValid
                withAnimation {
                    isShowMessage = errorMessage != nil && !isValid
                }
            })
            .onChange(of: focused, perform: {
                $0 ? focusHandler?() : unfocusHandler?()
            })
            .focused($focused)
            .onChange(of: text) { newValue in
                onChangeTextHandler?(newValue)
                if cleanHandler != nil {
                    withAnimation {
                        isShowCleanButton = !newValue.isEmpty
                    }
                }
            }
    }
}

enum InputTextFieldStatus: Equatable {
    case valid

    case undefined
    case unvalid
    case unvalidWithMessage(_ message: String)

    var isStateValidForField: Bool {
        self == .valid || self == .undefined
    }

    var isStateValidForAccept: Bool {
        self == .valid
    }
}
