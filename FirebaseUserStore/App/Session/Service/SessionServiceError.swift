import Foundation

enum SessionServiceError: Error {
    case errorWithAuth
    case undefinedUserDetails
}

extension SessionServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .errorWithAuth: return "Error with login"
        case .undefinedUserDetails: return "User is undefined"
        }
    }
}
