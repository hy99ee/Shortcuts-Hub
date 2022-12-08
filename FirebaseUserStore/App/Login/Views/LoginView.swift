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
                    store.dispatch(.openForgot(store: store))
                }, label: {
                    Text("Forgot Password?")
                })
                .font(.system(size: 16, weight: .bold))
            }
            
            VStack(spacing: 16) {
                
                ButtonView(title: "Login") {
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
        .modifier(SheetShowViewModifier(provider: store.state.registerSheet))
        .modifier(SheetShowViewModifier(provider: store.state.forgotSheet))
        .modifier(AlertShowViewModifier(provider: store.state.alert))
        .modifier(ProcessViewModifier(provider: store.state.processViewProgress))
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

struct InputTextFieldView: View {

    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let systemImage: String?

    private let textFieldLeading: CGFloat = 30

    var body: some View {
        VStack {
            TextField(placeholder, text: $text)
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
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    }
                )
        }
    }
}
