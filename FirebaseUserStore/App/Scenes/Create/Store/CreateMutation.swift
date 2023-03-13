import Foundation
import Combine

enum CreateMutation: Mutation {
    case setAppleItem(_ item: AppleApiItem)
    case itemUploaded

    case setError(_ error: CreateState.CreateErrorType)
    
    case progressButton(status: ProgressViewStatus)
    case progressView(status: ProgressViewStatus)
}
