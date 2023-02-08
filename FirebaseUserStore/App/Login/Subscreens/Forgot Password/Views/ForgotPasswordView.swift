import Combine
import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var store: ForgotStore
    @State private var email = ""
    @State private var errorButtonMessage: String?
    @State private var keyboardVisible = false

    var body: some View {
        VStack {
            textInput
                .padding(.bottom, 20)
            sendResetButton
        }
        .offset(y: -10)
        .padding(.horizontal, 14)
        .navigationTitle("Reset Password")
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
    }

    private var textInput: some View {
        InputTextFieldView(text: $email,
                           placeholder: "Email",
                           keyboardType: .emailAddress,
                           systemImage: "envelope",
                           errorMessage: errorMessageForEmailField,
                           isValid: isValidForEmailField,
                           unfocusHandler: { store.dispatch(.checkEmailField(email)) }
        )
    }

    private var sendResetButton: some View {
        ButtonView(title: "Send Password Reset", disabled: .constant(!email.isEmail)) {
            store.dispatch(.clickForgot(email: email))
        }
        .modifier(ButtonProgressViewModifier(provider: store.state.progress, type: .buttonView))
        .opacity(keyboardVisible ? 0 : 1)
        .onReceive(Publishers.keyboardVisible) { visible in
            if visible {
                self.keyboardVisible = true
            } else {
                withAnimation {
                    self.keyboardVisible = false
                }
            }
        }
    }

    private var errorMessageView: some View {
        HStack {
            Text(errorButtonMessage!)
                .font(.system(size: 13, design: .monospaced)).bold().foregroundColor(.red)
            Spacer()
        }
    }

    private var errorMessageForEmailField: Binding<String?> {
        Binding(
            get: {
                store.state.emailErrorMessage
            }, set: { _ in }
        )
    }
    private var isValidForEmailField: Binding<Bool> {
        Binding(
         get: {
             store.state.emailErrorMessage == nil
         }, set: { _, _ in
             store.dispatch(.clickEmailField)
         }
        )
    }
    
}
