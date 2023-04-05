import Foundation

enum LoginServiceError: Error {
    case firebaseError(_ error: Error)
}
