import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: LoginStore
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                InputTextFieldView(text: $email,
                                   placeholder: "Email",
                                   keyboardType: .emailAddress,
                                   systemImage: "envelope")
                InputPasswordView(password: $password,
                                  placeholder: "Password",
                                  systemImage: "lock")
            }

            HStack {
                Spacer()
                Button(action: {
                    store.dispatch(.openForgot)
                }, label: {
                    Text("Forgot Password?")
                })
                .font(.system(size: 16, weight: .bold))
            }

            VStack(spacing: 16) {
                ButtonView(title: "Login", disabled: .constant((!email.isEmail || password.isEmpty))) {
                    store.dispatch(.clickLogin(user: LoginCredentials(email: email, password: password)))
                }
                .modifier(ButtonProgressViewModifier(provider: store.state.loginProgress, type: .buttonView))

                ButtonView(title: "Register",
                           background: .clear,
                           foreground: .blue,
                           border: .blue) {
                    store.dispatch(.openRegister(store: store))
                }
            }
        }
//        .modifier(AlertShowViewModifier(provider: store.state.alert))
        .modifier(ProcessViewModifier(provider: store.state.processView))
        .padding(.horizontal, 15)
        .navigationTitle("Login")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
        }
    }
}
