import SwiftUI
import Combine

struct ForgotState: StateType {
    var isValidEmailField = true
    let alert = AlertProvider()
    let forgotProgress = ProgressViewProvider()
    let processViewProgress: ProcessViewProvider

    init() {
        processViewProgress = ProcessViewProvider(forgotProgress)
    }
}
