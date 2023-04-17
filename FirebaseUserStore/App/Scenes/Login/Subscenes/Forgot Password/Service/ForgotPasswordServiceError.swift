import Foundation

enum ForgotServiceError: Error {
    case firebaseError(_ error: Error)

    case mockError
}
