import Combine
import SwiftUDF
import SwiftUI

struct ForgotState: StateType, ReinitableByNewSelf {
    var progress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable

    var emailErrorMessage: String?
}
