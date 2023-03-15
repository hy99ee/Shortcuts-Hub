import Foundation
import Combine

enum CreateMutation: Mutation {
    case setAppleItem(_ item: AppleApiItem, linkFromUser: String)
    case itemUploaded(_ item: Item)

    case setError(_ error: CreateState.CreateErrorType)
    case linkFieldStatus(_ status: InputTextFieldStatus)
    
    case progressButton(status: ProgressViewStatus)
    case progressView(status: ProgressViewStatus)
}
