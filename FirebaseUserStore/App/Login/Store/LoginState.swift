import SwiftUI
import Combine

struct LoginState: StateType {
    var loginProgress: ProgressViewStatus = .stop
    var registerProgress: ProgressViewStatus = .stop
    var forgotProgress: ProgressViewStatus = .stop

    var processView: ProcessViewStatus = .enable
}
