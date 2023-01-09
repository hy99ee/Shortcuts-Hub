import SwiftUI
import Combine

struct LoginState: StateType {
    let registerSheet = RegisterSheetProvider()
    let forgotSheet = ForgotSheetProvider()

    let alert = AlertProvider()

    let loginProgress = ProgressViewProvider()
    let registerProgress = ProgressViewProvider()
    let forgotProgress = ProgressViewProvider()

    let processViewProgress: ProcessViewProvider

    init() {
        processViewProgress = ProcessViewProvider(loginProgress, registerProgress, forgotProgress)
    }
}
