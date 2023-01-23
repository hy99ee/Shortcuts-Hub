import SwiftUI
import Combine

struct ForgotState: StateType {
    let progress = ProgressViewProvider()
    let processView: ProcessViewProvider

    var emailErrorMessage: String?

    init() {
        processView = ProcessViewProvider(progress)
    }
}
