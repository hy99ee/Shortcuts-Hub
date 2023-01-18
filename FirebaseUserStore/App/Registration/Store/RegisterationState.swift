import SwiftUI
import Combine

struct RegisterationState: StateType {
    var fieldsStatus: [RegistrationCredentialsField: Bool] = {
//        var fields = [RegistrationCredentialsField: Bool]()
        RegistrationCredentialsField.allCases.reduce([RegistrationCredentialsField: Bool](), { _partialResult, registrationCredentialsField in
//            partialResult[registrationCredentialsField] = true
            var partialResult = _partialResult
            partialResult.updateValue(true, forKey: registrationCredentialsField)
            return partialResult
        })
    }()

    let alert = AlertProvider()
    let progress = ProgressViewProvider()
    lazy var processView = ProcessViewProvider(progress)
}
