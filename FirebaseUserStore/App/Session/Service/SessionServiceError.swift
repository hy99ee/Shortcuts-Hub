import Foundation

enum SessionServiceError: Error {
    case undefinedUserDetails
}

extension SessionServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .undefinedUserDetails: return "User is undefined"
        }
    }
}
