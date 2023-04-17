import SwiftUI
import Combine

struct CreateState: StateType, ReinitableByNewSelf {
    enum CreateErrorType: Error {
        case link
        case upload
        case auth
    }

    var item: Item?
    var appleItem: AppleApiItem?

    var error: CreateErrorType?
    var linkField: InputTextFieldStatus = .undefined

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop

    var processView: ProcessViewStatus = .disable
}
