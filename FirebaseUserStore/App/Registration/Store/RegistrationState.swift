import SwiftUI
import Combine

struct RegistrationState: StateType {
    var created: Bool = false
    var alertProvider = AlertProvider()
    var progressViewProvier = ProgressViewProvider()
}

extension RegistrationState {
}
