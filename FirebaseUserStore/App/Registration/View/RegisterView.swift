import SwiftUI
import Combine

struct RegisterView: View {
    @StateObject var store: RegisterationStore
    @State var newUser = RegistrationCredentials()
    @State var repeatPassword = false

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    InputTextFieldView(
                        text: $newUser.email,
                        placeholder: "Email",
                        keyboardType: .emailAddress,
                        systemImage: "envelope",
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
                        errorMessage: "Enter password without space",
                        isValid: createBindingForTextField(.password),
                        unfocusHandler: { store.dispatch(.check(field: .password, input: newUser.password)) }
                    )
                    
                    InputTextFieldView(
                        text: $newUser.conformPassword,
                        isSecureField: true,
                        placeholder: "Confirm password",
                        systemImage: "lock",
                        errorMessage: "Passwords isn't equal",
                        isValid: createBindingForTextField(.conformPassword),
                        unfocusHandler: { store.dispatch(.check(field: .conformPassword, input: newUser.password.combine(newUser.conformPassword))) }
                    )
                    .opacity(repeatPassword ? 1 : 0.5)
                    .disabled(!repeatPassword)
                    

                    Divider()
                        .padding(.vertical, 20)

                    InputTextFieldView(
                        text: $newUser.firstName,
                        placeholder: "First Name",
                        keyboardType: .namePhonePad,
                        systemImage: nil,
                        isValid: createBindingForTextField(.firstName),
                        unfocusHandler: { store.dispatch(.check(field: .firstName, input: newUser.firstName)) }
                    )

                    InputTextFieldView(
                        text: $newUser.lastName,
                        placeholder: "Last Name",
                        keyboardType: .namePhonePad,
                        systemImage: nil,
                        isValid: createBindingForTextField(.lastName),
                        unfocusHandler: { store.dispatch(.check(field: .lastName, input: newUser.lastName)) }
                    )
                    
                }

                ButtonView(title: "Sign up", disabled: .constant(!store.state.fieldsStatus.map { $0.value }.filter { !$0 }.isEmpty)) {
                    store.dispatch(.clickRegisteration(user: newUser))
                }
                .modifier(ButtonProgressViewModifier(provider: store.state.progress, type: .buttonView))
            }
            .padding(15)
            .navigationTitle("Register")
            .modifier(AlertShowViewModifier(provider: store.state.alert))
            .onChange(of: newUser.password) { newValue in
                withAnimation {
                    repeatPassword = newValue.isPassword
                    if !repeatPassword { newUser.conformPassword = "" }
                }
            }
        }
    }

    private func createBindingForTextField(_ field: RegistrationCredentialsField) -> Binding<Bool> {
        Binding(
            get: {
                store.state.fieldsStatus[field] ?? true
            }, set: { _ in
                store.dispatch(.click(field: field))
            }
        )
    }
}
