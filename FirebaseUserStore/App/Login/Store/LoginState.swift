import SwiftUI
import Combine

struct LoginState: StateType {
    var registerSheet = SheetProvider<RegisterView>()
    var forgotSheet = SheetProvider<ForgotPasswordView>()
    
    var alert = AlertProvider()

    var loginProgress = ProgressViewProvider()
    var registerProgress = ProgressViewProvider()
    var forgotProgress = ProgressViewProvider()
}
