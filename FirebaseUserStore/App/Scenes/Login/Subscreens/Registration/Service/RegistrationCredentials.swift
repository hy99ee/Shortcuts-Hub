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
extension RegistrationCredentials {
    func credentialsField(_ field: RegistrationCredentialsField) -> String {
        switch field {
        case .email:
            return self.email
        case .phone:
            return self.phone
        case .password:
            return self.password
        case .conformPassword:
            return self.conformPassword
        case .firstName:
            return self.firstName
        case .lastName:
            return self.lastName
        }
    }
}

enum RegistrationKeys: String {
    case firstName
    case lastName
    case phone
}
