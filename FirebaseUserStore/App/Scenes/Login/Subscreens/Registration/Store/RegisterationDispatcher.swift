import Foundation
import Combine
import SwiftUI

let registerationDispatcher: DispatcherType<RegisterationAction, RegisterationMutation, RegisterationPackages> = { action, packages in
    switch action {
    case let .check(field, input):
        return mutatationDefineFieldStatus(field, input).eraseToAnyPublisher()
    
    case let .click(field):
        return Just(RegisterationMutation.registrationCredentials((credentials: field, status: .undefined))).eraseToAnyPublisher()

    case let .clickRegisteration(user):
        return mutationRegisteration(user, packages: packages)
            .withStatus(start: RegisterationMutation.progressStatus(.start), finish: RegisterationMutation.progressStatus(.stop))

    case .cleanError:
        return Just(.setErrorMessage(nil)).eraseToAnyPublisher()
    }


    //MARK: Mutations
    func mutationRegisteration(_ user: RegistrationCredentials, packages: RegisterationPackages) -> AnyPublisher<RegisterationMutation, Never> {
        packages.registerationService.register(with: user)
//            .flatMap()
            .flatMap { _ in
                packages.sessionService.syncNewUserWithDatabase(user)
                    .mapError { _ in RegistrationServiceError.undefined }
            }
            .map { RegisterationMutation.close }
            .catch { _ in
                Just(RegisterationMutation.setErrorMessage(RegistrationServiceError.undefined))
            }
            .eraseToAnyPublisher()
    }

    func mutatationDefineFieldStatus(_ field: RegistrationCredentialsField, _ input: String) -> AnyPublisher<RegisterationMutation, Never> {
        Just({
            switch field {
            case .email:
                return .registrationCredentials((credentials: .email, status: input.isEmail ? .valid : .unvalidWithMessage("Unvalid email format")))
            case .phone:
                return .registrationCredentials((credentials: .phone, status: input.isPhone ? .valid : .unvalid))
            case .password:
                return .registrationCredentials((credentials: .password, status: input.passwordValidationMessage == nil ? .valid : .unvalidWithMessage(input.passwordValidationMessage!) ))
            case .conformPassword:
                return .registrationCredentials((credentials: .conformPassword, status: input.conformPasswordValidationMessage == nil ? .valid : .unvalidWithMessage(input.conformPasswordValidationMessage!)))
            case .firstName:
                return .registrationCredentials((credentials: .firstName, status: input.isUsername ? .valid : .unvalidWithMessage("Unvalid username format")))
            case .lastName:
                return .registrationCredentials((credentials: .lastName, status: input.isUsername ? .valid : .unvalidWithMessage("Unvalid lastname format")))
            }
        }()).eraseToAnyPublisher()
    }
}

