import SwiftUI
import Combine

struct ForgotState: StateType, ReinitableByNewSelf {
    var progress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable

    var emailErrorMessage: String?
}
