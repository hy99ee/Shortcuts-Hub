import SwiftUI
import Combine

struct ForgotState: StateType {
    var progress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable

    var emailErrorMessage: String?
}
