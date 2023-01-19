import SwiftUI
import Combine

struct RegisterationState: StateType {
    var fieldsStatus: [RegistrationCredentialsField: Bool] = {
        RegistrationCredentialsField.allCases.reduce([RegistrationCredentialsField: Bool](), { _partialResult, registrationCredentialsField in
            var partialResult = _partialResult
            partialResult.updateValue(true, forKey: registrationCredentialsField)
            return partialResult
        })
    }()

    let alert = AlertProvider()
    let progress = ProgressViewProvider()
    lazy var processView = ProcessViewProvider(progress)
}
