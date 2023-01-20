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
        .modifier(AlertShowViewModifier(provider: store.state.alert))
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
    private let unfocusHandler: (() -> ())?
    private let textFieldLeading: CGFloat = 30

    init(
        text: Binding<String>,
        isSecureField: Bool = false,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        systemImage: String? = nil,
        errorMessage: Binding<String?> = .constant(nil),
        isValid: Binding<Bool> = .constant(true),
        unfocusHandler: (() -> ())? = nil
    ) {
        self._text = text
        self.isSecureField = isSecureField
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.systemImage = systemImage
        self._errorMessage = errorMessage
        self._isValid = isValid
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
                    if !$0 { unfocusHandler?() }
                })
                .focused($focused)
        }
    }

    @ViewBuilder private var textViewByStyle: some View {
        if isSecureField { SecureField(placeholder, text: $text) } else { TextField(placeholder, text: $text) }
    }
}
