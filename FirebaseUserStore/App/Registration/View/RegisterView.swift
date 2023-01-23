import SwiftUI
import Combine

struct RegisterView: View {
    @StateObject var store: RegisterationStore
    @State private var newUser = RegistrationCredentials()
    @State private var repeatPassword = false
    @State private var errorButtonMessage: String?
    @State private var keyboardVisible = false
    
    private let animationTime = 2.0
    var interval: ClosedRange<Date> {
            let start = Date()
            let end = start.addingTimeInterval(5)
            return start...end
    }
    
    var body: some View {
        VStack {
            registerFields

            if errorButtonMessage != nil {
                errorMessageView
            }
            singUpButtonView
        }
        .padding(15)
        .navigationTitle("Register")
        .onChange(of: newUser.password) { password in
            withAnimation {
                repeatPassword = password.isPasswordMinCount && password.isPasswordMaxCount
                if !repeatPassword {
                    newUser.conformPassword = ""
                    store.dispatch(.click(field: .conformPassword))
                }
            }
        }
        .onChange(of: store.state.registrationErrorMessage) { message in
            withAnimation {
                errorButtonMessage = message
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
        
    }

    private var registerFields: some View {
        ScrollView(showsIndicators: false) {
            InputTextFieldView(
                text: $newUser.email,
                placeholder: "Email",
                keyboardType: .emailAddress,
                systemImage: "envelope",
                errorMessage: createBindingUnvalidMessage(.email),
                isValid: createBindingForTextField(.email),
                unfocusHandler: { store.dispatch(.check(field: .email, input: newUser.email)) }
            )
            
            InputTextFieldView(
                text: $newUser.phone,
                placeholder: "Mobile number",
                keyboardType: .phonePad,
                systemImage: "phone",
                isValid: createBindingForTextField(.phone),
                unfocusHandler: { store.dispatch(.check(field: .phone, input: newUser.phone)) }
            )
            
            InputTextFieldView(
                text: $newUser.password,
                isSecureField: true,
                placeholder: "Password",
                systemImage: "lock",
                errorMessage: createBindingUnvalidMessage(.password),
                isValid: createBindingForTextField(.password),
                unfocusHandler: { store.dispatch(.check(field: .password, input: newUser.password)) }
            )
            
            InputTextFieldView(
                text: $newUser.conformPassword,
                isSecureField: true,
                placeholder: "Confirm password",
                systemImage: "lock",
                errorMessage: createBindingUnvalidMessage(.conformPassword),
                isValid: createBindingForTextField(.conformPassword),
                unfocusHandler: { store.dispatch(.check(field: .conformPassword, input: newUser.password.combine(newUser.conformPassword))) }
            )
            .opacity(repeatPassword ? 1 : 0.5)
            .disabled(!repeatPassword)
            
            
            Divider()
                .padding(.vertical, 20)
                .padding(.horizontal, 3)
            
            InputTextFieldView(
                text: $newUser.firstName,
                placeholder: "First Name",
                keyboardType: .namePhonePad,
                errorMessage: createBindingUnvalidMessage(.firstName),
                isValid: createBindingForTextField(.firstName),
                unfocusHandler: { store.dispatch(.check(field: .firstName, input: newUser.firstName)) }
            )
            
            InputTextFieldView(
                text: $newUser.lastName,
                placeholder: "Last Name",
                keyboardType: .namePhonePad,
                errorMessage: createBindingUnvalidMessage(.lastName),
                isValid: createBindingForTextField(.lastName),
                unfocusHandler: { store.dispatch(.check(field: .lastName, input: newUser.lastName)) }
            )
        }
    }

    private var errorMessageView: some View {
        VStack {
            HStack {
                Spacer()
                ProgressWheel(total: 5 - animationTime).frame(width: 18, height: 18)
            }
            HStack {
                Text(errorButtonMessage!)
                    .font(.system(size: 13, design: .monospaced)).bold().foregroundColor(.red)
                Spacer()
            }
        }
    }

    private var singUpButtonView: some View {
        ButtonView(title: "Sign up", disabled: .constant(!store.state.singUpButtonValid || store.state.registrationErrorMessage != nil)) {
            store.dispatch(.clickRegisteration(user: newUser))
        }
        .opacity(keyboardVisible ? 0 : 1)
        .padding(.bottom, keyboardVisible ? -300 : 0)
        .modifier(ButtonProgressViewModifier(provider: store.state.progress, type: .buttonView))
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

    private func createBindingForTextField(_ field: RegistrationCredentialsField) -> Binding<Bool> {
        Binding(
            get: {
                (store.state.fieldsStatus[field] ?? .undefined).isStateValidForField
            }, set: { _ in
                store.dispatch(.click(field: field))
            }
        )
    }

    private func createBindingUnvalidMessage(_ field: RegistrationCredentialsField) -> Binding<String?> {
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
}
