import SwiftUI
import Combine

enum RegistrationFieldStatus: Equatable {
    case valid

    case undefined
    case unvalid
    case unvalidWithMessage(_ message: String)

    var isStateValidForField: Bool {
        self == .valid || self == .undefined
    }

    var isStateValidForAccept: Bool {
        self == .valid
    }
}

struct RegisterationState: StateType {
    var fieldsStatus: [RegistrationCredentialsField: RegistrationFieldStatus] = {
        RegistrationCredentialsField.allCases.reduce([RegistrationCredentialsField: RegistrationFieldStatus](), { _partialResult, registrationCredentialsField in
            var partialResult = _partialResult
            partialResult.updateValue(.undefined, forKey: registrationCredentialsField)
            return partialResult
        })
    }()

    var singUpButtonValid = false

    let alert = AlertProvider()
    let progress = ProgressViewProvider()
    lazy var processView = ProcessViewProvider(progress)
}
