import Foundation
import Combine
import SwiftUI

let registerationDispatcher: DispatcherType<RegisterationAction, RegisterationMutation, RegisterationPackages> = { action, packages in
    switch action {
    case let .clickRegisteration(user):
        return mutationRegisteration(user, packages: packages)
            .withStatus(start: RegisterationMutation.progressStatus(.start), finish: RegisterationMutation.progressStatus(.stop))

    case let .check(field, input):
        return mutatationCalculateFieldStatus(field, input).eraseToAnyPublisher()
    
    case let .click(field):
        return Just(RegisterationMutation.registrationCredentials((credentials: field, status: true))).eraseToAnyPublisher()
    }


    //MARK: Mutations
    func mutationRegisteration(_ user: RegistrationCredentials, packages: RegisterationPackages) -> AnyPublisher<RegisterationMutation, Never> {
        packages.registerationService.register(with: user)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { RegisterationMutation.close }
            .catch { _ in Just(RegisterationMutation.errorAlert(error: RegistrationServiceError.undefined)) }
            .eraseToAnyPublisher()
    }

    func mutatationCalculateFieldStatus(_ field: RegistrationCredentialsField, _ input: String) -> AnyPublisher<RegisterationMutation, Never> {
        Just({
            switch field {
            case .email:
                return RegisterationMutation.registrationCredentials((credentials: .email, status: input.isEmail))
            case .phone:
                return RegisterationMutation.registrationCredentials((credentials: .phone, status: input.isPhone))
            case .password:
                return RegisterationMutation.registrationCredentials((credentials: .password, status: input.isPassword))
            case .conformPassword:
                return RegisterationMutation.registrationCredentials((credentials: .conformPassword, status: input.isEqualDoublePassword))
            case .firstName:
                return RegisterationMutation.registrationCredentials((credentials: .firstName, status: input.isUsername))
            case .lastName:
                return RegisterationMutation.registrationCredentials((credentials: .lastName, status: input.isUsername))
            }
        }()).eraseToAnyPublisher()
    }
}

