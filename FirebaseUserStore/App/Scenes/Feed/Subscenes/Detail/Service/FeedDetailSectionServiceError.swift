import Foundation

enum FeedDetailSectionServiceError: Error {
    case firebaseError(_ error: Error)
    case undefined
}
