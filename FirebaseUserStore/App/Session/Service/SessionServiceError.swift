import Foundation

enum SessionServiceError: Error {
    case errorWithAuth
    case errorWithCreateNewUser
    case undefinedUserDetails
}

extension SessionServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .errorWithAuth: return "Error with login"
        case .errorWithCreateNewUser: return "Error with create new user"
        case .undefinedUserDetails: return "User is undefined"
        }
    }
}
