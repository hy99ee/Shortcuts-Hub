import Foundation
import Combine

enum CreateMutation: Mutation {
    case itemUpdate
    case itemUploaded

    case setError(_ error: CreateState.CreateErrorType)
    
    case progressButtonStatus(status: ProgressViewStatus)
    case progressViewStatus(status: ProgressViewStatus)
}
