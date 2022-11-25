import SwiftUI
import Combine

struct LoginState: StateType {
    var registerProvider = SheetProvider<RegisterView>()
    var forgotProvider = SheetProvider<ForgotPasswordView>()
    
    var alertProvider = AlertProvider()
    var progressViewProvier = ProgressViewProvider()
}
