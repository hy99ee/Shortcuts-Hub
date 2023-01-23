import SwiftUI

struct InputTextFieldView: View {
    @Binding var text: String
    let isSecureField: Bool
    let placeholder: String
    let keyboardType: UIKeyboardType
    let systemImage: String?
    @Binding var errorMessage: String?
    @Binding var isValid: Bool

    @State private var isShowMessage = false
    @FocusState private var focused: Bool
    private let textFieldLeading: CGFloat = 30

    private let focusHandler: (() -> ())?
    private let unfocusHandler: (() -> ())?

    init(
        text: Binding<String>,
        isSecureField: Bool = false,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        systemImage: String? = nil,
        errorMessage: Binding<String?> = .constant(nil),
        isValid: Binding<Bool> = .constant(true),
        focusHandler: (() -> ())? = nil,
        unfocusHandler: (() -> ())? = nil
    ) {
        self._text = text
        self.isSecureField = isSecureField
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.systemImage = systemImage
        self._errorMessage = errorMessage
        self._isValid = isValid
        self.focusHandler = focusHandler
        self.unfocusHandler = unfocusHandler
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
        self.focusHandler = nil
        self.unfocusHandler = nil
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
            
            textViewByStyle
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
                    withAnimation(.easeIn(duration: 10)) {
                        isValid = true
                    }
                }
                .onChange(of: isValid, perform: { isValid in
                    focused = isValid
                    if errorMessage != nil && !isValid {
                        withAnimation {
                            isShowMessage = true
                        }
                    } else {
                        withAnimation {
                            isShowMessage = false
                        }
                    }
                })
                .onChange(of: focused, perform: {
                    $0 ? focusHandler?() : unfocusHandler?()
                })
                .focused($focused)
                .onChange(of: text) { _ in
                    if keyboardType == .phonePad, text.isPhone {
                        focused = false
                    }
                }
        }
        .padding(3)
    }

    @ViewBuilder private var textViewByStyle: some View {
        if isSecureField { SecureField(placeholder, text: $text) } else { TextField(placeholder, text: $text) }
    }

//    @State private var isBeginPhoneEditing = true
//    private func phoneUdapter() {
//        if text.isPhone {
//            withAnimation {
//                focused = false
//            }
//        }
//    }
//
//    private func byPhoneTextModifier() {
//        switch text.count {
//        case 0:
//            phonesChanges.updateValue(false, forKey: 1)
//        case 1:
//            if !(phonesChanges[1] ?? true) {
//                text = "+7 (" + text
//            }
//            phonesChanges.updateValue(false, forKey: 8)
//            phonesChanges.updateValue(true, forKey: 1)
//        case 4:
//            text = ""
//        case 8:
//            if !(phonesChanges[8] ?? true) {
//                text = String(text.dropLast()) + ") - " + String(text.last!)
//            }
//            phonesChanges.updateValue(false, forKey: 13)
//            phonesChanges.updateValue(true, forKey: 7)
//        case 11:
//            text = String(text.dropLast(4))
//        case 15:
//            if !(phonesChanges[13] ?? true) {
//                text = String(text.dropLast()) + " - " + String(text.last!)
//            }
//            phonesChanges.updateValue(true, forKey: 13)
//        case 17:
//            text = String(text.dropLast(3))
//        default: break
//        }
//    }
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
