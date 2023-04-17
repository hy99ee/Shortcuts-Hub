import SwiftUI
import Combine

struct LoginState: StateType, ReinitableByNewSelf {
    var fieldsStatus: [LoginCredentialsField: InputTextFieldStatus] = {
        LoginCredentialsField.allCases.reduce([LoginCredentialsField: InputTextFieldStatus](), { _partialResult, registrationCredentialsField in
            var partialResult = _partialResult
            partialResult.updateValue(.undefined, forKey: registrationCredentialsField)
            return partialResult
        })
    }()

    var singUpButtonValid = false
    var loginErrorMessage: String?

    var viewProgress: ProgressViewStatus = .stop
    var registerProgress: ProgressViewStatus = .stop
    var forgotProgress: ProgressViewStatus = .stop

    var processView: ProcessViewStatus = .enable
}
