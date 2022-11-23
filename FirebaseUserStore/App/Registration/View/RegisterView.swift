import SwiftUI
import Combine

struct RegisterView<Store: RegistrationStore>: View {

    @EnvironmentObject var store: Store
    @State var newUser = RegistrationCredentials(email: "", password: "", firstName: "", lastName: "", occupation: "")
    var body: some View {

        NavigationView {

            VStack(spacing: 32) {

                VStack(spacing: 16) {

                    InputTextFieldView(text: $newUser.email,
                                       placeholder: "Email",
                                       keyboardType: .emailAddress,
                                       systemImage: "envelope")

                    InputPasswordView(password: $newUser.password,
                                      placeholder: "Password",
                                      systemImage: "lock")

                    Divider()

                    InputTextFieldView(text: $newUser.firstName,
                                       placeholder: "First Name",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)

                    InputTextFieldView(text: $newUser.lastName,
                                       placeholder: "Last Name",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)

                    InputTextFieldView(text: $newUser.occupation,
                                       placeholder: "Occupation",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)
                }

                ButtonView(title: "Sign up") {
                    store.dispatch(.create(newUser: newUser))
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Register")
            .applyClose()
            .modifier(AlertShowViewModifier(provider: store.state.alertProvider))
        }
    }
}
