import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: LoginStore

    @State private var email = ""
    @State private var password = ""

    @FocusState private var focusedField: LoginCredentialsField?
    @State private var errorButtonMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                InputTextFieldView(
                    text: $email,
                    placeholder: "Email",
                    keyboardType: .emailAddress,
                    systemImage: "envelope",
                    errorMessage: createBindingUnvalidMessage(.email),
                    isValid: createBindingForTextField(.email),
                    unfocusHandler: {
                        store.dispatch(.check(field: .email, input: email))
                    }
                )
                .focused($focusedField, equals: .email)
                .textContentType(.emailAddress)
                .submitLabel(.next)

                InputTextFieldView(
                    text: $password,
                    isSecureField: true,
                    placeholder: "Password",
                    systemImage: "lock",
                    errorMessage: createBindingUnvalidMessage(.password),
                    isValid: createBindingForTextField(.password),
                    unfocusHandler: { store.dispatch(.check(field: .password, input: password)) }
                )
                .focused($focusedField, equals: .password)
                .textContentType(.newPassword)
                .submitLabel(.next)
            }
            .onSubmit {
                let tempFocusField = focusedField
                focusedField = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    if !store.state.singUpButtonValid {
                        onSubmitAction(field: tempFocusField)
                    }
                }
            }
            .onChange(of: focusedField) { newFocus in
                switch newFocus {
                case let .some(field):
                    store.dispatch(.click(field: field))
                case .none:
                    break
                }
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
                if errorButtonMessage != nil {
                    errorMessageView
                }
                ButtonView(title: "Login", disabled: .constant(!ableToClick)) {
                    store.dispatch(.clickLogin(user: LoginCredentials(email: email, password: password)))
                }
                .modifier(ButtonProgressViewModifier(progressStatus: store.state.viewProgress, type: .buttonView))

                ButtonView(title: "Register",
                           background: .clear,
                           foreground: .blue,
                           border: .blue) {
                    store.dispatch(.openRegister(store: store))
                }
            }
        }
        .onChange(of: store.state.loginErrorMessage) { message in
            withAnimation {
                errorButtonMessage = message
            }
        }
        .modifier(ProcessViewModifier(process: store.state.processView))
        .padding(.horizontal, 15)
        .navigationTitle("Login")
    }

    private func createBindingForTextField(_ field: LoginCredentialsField) -> Binding<Bool> {
        Binding(
            get: {
                (store.state.fieldsStatus[field] ?? .undefined).isStateValidForField
            }, set: { _ in
                store.dispatch(.click(field: field))
            }
        )
    }

    private func createBindingUnvalidMessage(_ field: LoginCredentialsField) -> Binding<String?> {
        Binding(
            get: {
                if case let .unvalidWithMessage(message) = store.state.fieldsStatus[field] {
                    return message
                } else {
                    return nil
                }
            }, set: { _ in
                
            }
        )
    }

    private func onSubmitAction(field: LoginCredentialsField?) {
        focusedField = field != nil
        ? findNotEmptyNextFocus(for: field!)
        : nil
    }

    
    private var ableToClick: Bool {
        store.state.singUpButtonValid && store.state.loginErrorMessage == nil
    }
    
    private func findNotEmptyNextFocus(for field: LoginCredentialsField) -> LoginCredentialsField? {
        if let next = nextFocus(for: field), store.state.fieldsStatus[next]! == .valid {
            return !ableToClick ? findNotEmptyNextFocus(for: next) : nil
        } else {
            return nextFocus(for: field)
        }
    }

    private func nextFocus(for field: LoginCredentialsField) -> LoginCredentialsField? {
        switch field {
        case .email:
            return .password
        case .password:
            return .email
        }
    }

    private var errorMessageView: some View {
        VStack {
            HStack {
                Spacer()
                ProgressWheel(total: 3).frame(width: 18, height: 18)
            }
            HStack {
                Text(errorButtonMessage!)
                    .font(.system(size: 13, design: .monospaced)).bold().foregroundColor(.red)
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                store.dispatch(.cleanError)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
        }
    }
}
