import SwiftUI
import Combine

struct CreateState: StateType {
    enum CreateErrorType: Error {
        case link
        case upload
        case auth
    }

    var item: Item?
    var appleItem: AppleApiItem?

    var error: CreateErrorType?

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop

    var processView: ProcessViewStatus = .disable
}
