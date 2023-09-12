import SwiftUDF

enum ForgotAction: Action {
    case clickForgot(email: String)

    case clickEmailField
    case checkEmailField(_ input: String)
}

