import SwiftUI
import Combine

enum RegistrationFieldStatus: Equatable {
    case valid
    case unvalid
    case unvalidWithMessage(_ message: String)
}

struct RegisterationState: StateType {
    var fieldsStatus: [RegistrationCredentialsField: RegistrationFieldStatus] = {
        RegistrationCredentialsField.allCases.reduce([RegistrationCredentialsField: RegistrationFieldStatus](), { _partialResult, registrationCredentialsField in
            var partialResult = _partialResult
            partialResult.updateValue(.valid, forKey: registrationCredentialsField)
            return partialResult
        })
    }()

    let alert = AlertProvider()
    let progress = ProgressViewProvider()
    lazy var processView = ProcessViewProvider(progress)
}
