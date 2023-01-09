import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var store: ForgotStore
    @State private var email = ""
    
    var body: some View {
            VStack(spacing: 16) {
                InputTextFieldView(text: $email,
                                   placeholder: "Email",
                                   keyboardType: .emailAddress,
                                   systemImage: "envelope",
                                   isValid:
                                    Binding(
                                    get: {
                                        store.state.isValidEmailField
                                    }, set: { value, _ in
                                        store.dispatch(.clickEmailField)
                                    })
                )
                
                ButtonView(title: "Send Password Reset") {
                    store.dispatch(.clickForgot(email: email))
                }
                .modifier(ButtonProgressViewModifier(provider: store.state.forgotProgress, type: .buttonView))
            }
            .modifier(AlertShowViewModifier(provider: store.state.alert))
            .padding(.horizontal, 15)
            .navigationTitle("Reset Password")
            .applyClose()
    }
}
