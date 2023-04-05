import SwiftUI
import Combine

struct RegisterView: View {
    @StateObject var store: RegisterationStore
    @State private var newUser = RegistrationCredentials()
    @State private var repeatPassword = false
    @State private var errorButtonMessage: String?

    @FocusState private var focusedField: RegistrationCredentialsField?
    @State private var keyboardVisible = false

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
        .modifier(DismissingKeyboard())
        .padding(15)
        .navigationTitle("Register")
        .onReceive(Publishers.keyboardVisible) { visible in
            if visible {
                self.keyboardVisible = true
            } else {
                withAnimation {
                    self.keyboardVisible = false
                }
            }
        }
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
                unfocusHandler: {
                    store.dispatch(.check(field: .email, input: newUser.email))
                }
            )
            .focused($focusedField, equals: .email)
            .textContentType(.emailAddress)
            .submitLabel(.next)
            
            InputTextFieldView(
                text: $newUser.phone,
                placeholder: "Mobile number",
                keyboardType: .phonePad,
                systemImage: "phone",
                isValid: createBindingForTextField(.phone),
                unfocusHandler: {
                    store.dispatch(.check(field: .phone, input: newUser.phone))
                },
                onChangeTextHandler: {
                    if $0.isPhone {
                        store.dispatch(.check(field: .phone, input: newUser.phone))
//                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                            let focused = findNotEmptyNextFocus(for: .phone)
                            focusedField = focused == .phone ? nil : focused
//                        }
                    }
                }
            )
            .focused($focusedField, equals: .phone)
            .textContentType(.telephoneNumber)
            
            InputTextFieldView(
                text: $newUser.password,
                isSecureField: true,
                placeholder: "Password",
                systemImage: "lock",
                errorMessage: createBindingUnvalidMessage(.password),
                isValid: createBindingForTextField(.password),
                unfocusHandler: { store.dispatch(.check(field: .password, input: newUser.password)) }
            )
            .focused($focusedField, equals: .password)
            .textContentType(.newPassword)
            .submitLabel(.next)
            
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
            .focused($focusedField, equals: .conformPassword)
            .textContentType(.newPassword)
            .submitLabel(.next)

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
            .focused($focusedField, equals: .firstName)
            .textContentType(.name)
            .submitLabel(.next)

            InputTextFieldView(
                text: $newUser.lastName,
                placeholder: "Last Name",
                keyboardType: .namePhonePad,
                errorMessage: createBindingUnvalidMessage(.lastName),
                isValid: createBindingForTextField(.lastName),
                unfocusHandler: { store.dispatch(.check(field: .lastName, input: newUser.lastName)) }
            )
            .focused($focusedField, equals: .lastName)
            .textContentType(.familyName)
            .submitLabel(.next)
        }
        .onSubmit {
            let tempFocusField = focusedField
            focusedField = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                if ableToClick {
                    store.dispatch(.clickRegisteration(user: newUser))
                } else if !store.state.singUpButtonValid {
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

    private var singUpButtonView: some View {
        ButtonView(title: "Sign up", disabled: .constant(!ableToClick)) {
            store.dispatch(.clickRegisteration(user: newUser))
        }
        .opacity(keyboardVisible ? 0 : 1)
        .padding(.bottom, keyboardVisible ? -300 : 0)
        .modifier(ButtonProgressViewModifier(progressStatus: store.state.progress, type: .buttonView))
    }

    private func onSubmitAction(field: RegistrationCredentialsField?) {
        switch field {
        case .email:
            focusedField = findNotEmptyNextFocus(for: .email)
        case .phone:
            focusedField = findNotEmptyNextFocus(for: .phone)
        case .password:
            if store.state.fieldsStatus[.password]! == .valid {
                focusedField = findNotEmptyNextFocus(for: .password)
            }
        case .conformPassword:
            if store.state.fieldsStatus[.conformPassword]! == .valid {
                focusedField = findNotEmptyNextFocus(for: .conformPassword)
            }
        case .firstName:
            focusedField = findNotEmptyNextFocus(for: .firstName)
        case .lastName:
            focusedField = findNotEmptyNextFocus(for: .lastName)
        default:
            break
        }
    }

    private func findNotEmptyNextFocus(for field: RegistrationCredentialsField) -> RegistrationCredentialsField? {
        if let next = nextFocus(for: field), store.state.fieldsStatus[next]! == .valid {
            return !ableToClick ? findNotEmptyNextFocus(for: next) : nil
        } else {
            return nextFocus(for: field)
        }
    }

    private func nextFocus(for field: RegistrationCredentialsField) -> RegistrationCredentialsField? {
        switch field {
        case .email:
            return .phone
        case .phone:
            return .password
        case .password:
            return .conformPassword
        case .conformPassword:
            return .firstName
        case .firstName:
            return .lastName
        case .lastName:
            return .email
        }
    }

    private var ableToClick: Bool {
        store.state.singUpButtonValid && store.state.registrationErrorMessage == nil
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
