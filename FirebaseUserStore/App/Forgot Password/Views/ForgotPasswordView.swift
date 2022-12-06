import SwiftUI

struct ForgotPasswordView: View {
//    @Environment(\.presentationMode) var presentationMode
    @StateObject var store: LoginStore
    @State private var email = ""
    
    var body: some View {
            VStack(spacing: 16) {
            
                InputTextFieldView(text: $email,
                                   placeholder: "Email",
                                   keyboardType: .emailAddress,
                                   systemImage: "envelope")
                
                ButtonView(title: "Send Password Reset") {
                    store.dispatch(.clickForgot(email: email))
                    
//                    viewModel.sendPasswordResetRequest()
//                    presentationMode.wrappedValue.dismiss()
                }
                .modifier(ButtonProgressViewModifier(provider: store.state.forgotProgress))
            }
            .modifier(AlertShowViewModifier(provider: store.state.alert))
            .padding(.horizontal, 15)
            .navigationTitle("Reset Password")
            .applyClose()
    }
}
