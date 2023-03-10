import Foundation
import Combine

enum CreateMutation: Mutation {
    case itemUpdate
    case itemUploaded

    case setError(_ error: CreateState.CreateErrorType)
    
    case progressButton(status: ProgressViewStatus)
    case progressView(status: ProgressViewStatus)
}
