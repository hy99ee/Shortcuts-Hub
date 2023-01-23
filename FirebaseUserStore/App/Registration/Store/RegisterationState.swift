import SwiftUI
import Combine

struct RegisterationState: StateType {
    var fieldsStatus: [RegistrationCredentialsField: InputTextFieldStatus] = {
        RegistrationCredentialsField.allCases.reduce([RegistrationCredentialsField: InputTextFieldStatus](), { _partialResult, registrationCredentialsField in
            var partialResult = _partialResult
            partialResult.updateValue(.undefined, forKey: registrationCredentialsField)
            return partialResult
        })
    }()

    var singUpButtonValid = false
    var registrationErrorMessage: String?

    let progress = ProgressViewProvider()
    lazy var processView = ProcessViewProvider(progress)
}
