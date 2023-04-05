import Foundation

enum LoginCredentialsField: CaseIterable {
    case email
    case password
}

struct LoginCredentials {
    var email: String
    var password: String
}
