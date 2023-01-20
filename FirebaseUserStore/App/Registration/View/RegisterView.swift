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

                ButtonView(title: "Sign up", disabled: .constant(!store.state.fieldsStatus.map { $0.value == .valid }.filter { !$0 }.isEmpty)) {
                    store.dispatch(.clickRegisteration(user: newUser))
                }
                .modifier(ButtonProgressViewModifier(provider: store.state.progress, type: .buttonView))
            }
            .padding(15)
            .navigationTitle("Register")
            .modifier(AlertShowViewModifier(provider: store.state.alert))
            .onChange(of: newUser.password) { newValue in
                withAnimation {
                    repeatPassword = newValue.isPasswordMinCount && newValue.isPasswordMaxCount
                    if !repeatPassword {
                        newUser.conformPassword = ""
                        store.dispatch(.click(field: .conformPassword))
                    }
                }
            }
        }
    }

    private func createBindingForTextField(_ field: RegistrationCredentialsField) -> Binding<Bool> {
        Binding(
            get: {
                store.state.fieldsStatus[field] ?? .valid == .valid
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
