import SwiftUI
import FirebaseAuth

struct AboutViewData {
    let user: UserDetails

    let logout: () -> ()
    let delete: () -> ()
}

struct AboutView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var alertShow = false

    let user: UserDetails

    let logout: () -> ()
    let delete: () -> ()

    private let accountImageSize = 80.0

    init(aboutData: AboutViewData) {
        self.user = aboutData.user
        self.logout = aboutData.logout
        self.delete = aboutData.delete
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            Text(
                String(user.value!.firstName.first ?? Character(" ")) +
                String(user.value!.lastName.first ?? Character(" "))
            )
            .font(.largeTitle)
            .frame(width: accountImageSize, height: accountImageSize, alignment: .center)
            .overlay(
                Text("Edit")
                    .padding(.bottom, 3)
                    .padding(.leading, 2)
                    .frame(width: accountImageSize)
                    .font(.system(size: 12).smallCaps())
                    .background(.black)
                    .foregroundColor(.gray),
                alignment: .bottom
            )
            .background(Color.random)
            .cornerRadius(accountImageSize / 2)
            .padding(.top, 30)
            
            VStack {
                Text(user.value!.firstName).font(.title).fontWeight(.semibold)
                Text(user.auth!.email.0).font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            }
            .padding()

            NavigationView {
                Form {
                    Section("account") {
                        Button {
                            logout()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Logout").foregroundColor(.primary)
                        }

                        Button {
                            alertShow = true
                        } label: {
                            Text("Remove account").foregroundColor(.red)
                        }
                    }
                }
            }
            .frame(height: 400)
            .cornerRadius(12)
        }
        .navigationBarItems(trailing: AppearanceButton())
        .alert("Are you sure?", isPresented: $alertShow) {
            Button("Yes", role: .destructive, action: {
                delete()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var firstName = "Mock first name"
    static var lastName = "Mock last name"
    static var mail = "mail@mail.com"

    static var previews: some View {
        AboutView(
            aboutData:
                AboutViewData(
                    user:
                        UserDetails(
                            value:
                                DatabaseUser(
                                    firstName: firstName,
                                    lastName: lastName,
                                    phone: "+12003004050"
                                ),
                            auth:
                                UserAuthDetails(
                                    id: "",
                                    email: ("mockmail@mail.ru", isVerified: true)
                                ),
                            savedIds: []
                        ),
                    logout: {},
                    delete: {}
                )
        )
    }
}
