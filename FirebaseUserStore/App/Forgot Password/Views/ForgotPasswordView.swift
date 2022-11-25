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
                    store.dispatch(.openForgot(store: store))
//                    viewModel.sendPasswordResetRequest()
//                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Reset Password")
            .applyClose()
    }
}
