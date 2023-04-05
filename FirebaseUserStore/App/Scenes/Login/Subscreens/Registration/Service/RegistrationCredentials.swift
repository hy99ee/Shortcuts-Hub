import Foundation

enum RegistrationCredentialsField: CaseIterable {
    case email
    case phone
    case password
    case conformPassword
    case firstName
    case lastName
}

struct RegistrationCredentials {
    var email = ""
    var phone = ""
    var password = ""
    var conformPassword = ""
    var firstName = ""
    var lastName = ""
}
