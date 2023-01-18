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
                    InputTextFieldView(text: $newUser.email,
                                       placeholder: "Email",
                                       keyboardType: .emailAddress,
                                       systemImage: "envelope")

                    InputTextFieldView(text: $newUser.phone,
                                       placeholder: "Mobile number",
                                       keyboardType: .phonePad,
                                       systemImage: "phone")

                    InputPasswordView(password: $newUser.password,
                                      placeholder: "Password",
                                      systemImage: "lock")
                    
                    InputPasswordView(password: $newUser.repeatPassword,
                                      placeholder: "Confirm password",
                                      systemImage: "lock")
                    .opacity(repeatPassword ? 1 : 0.5)
                    .disabled(!repeatPassword)
                    

                    Divider()
                        .padding(.vertical, 20)

                    InputTextFieldView(text: $newUser.firstName,
                                       placeholder: "First Name",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)

                    InputTextFieldView(text: $newUser.lastName,
                                       placeholder: "Last Name",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)
                    
                }
                Spacer()

                ButtonView(title: "Sign up", disabled: .constant(!newUser.isValid)) {
                    store.dispatch(.clickRegisteration(user: newUser))
                }
                .modifier(ButtonProgressViewModifier(provider: store.state.progress, type: .buttonView))
            }
            .padding(15)
            .navigationTitle("Register")
            .modifier(AlertShowViewModifier(provider: store.state.alert))
            .onChange(of: newUser.password) { newValue in
                withAnimation {
                    let isCorrectPassword = newValue.isPassword
                    repeatPassword = isCorrectPassword
                    if !isCorrectPassword {
                        newUser.repeatPassword = ""
                    }
                }
            }
        }
    }
}
