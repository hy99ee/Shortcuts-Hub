import Foundation
import Combine
import SwiftUI

let loginDispatcher: DispatcherType<LoginAction, LoginMutation, LoginPackages> = { action, packages in
    switch action {
    case let .openRegister(store):
        return Just(.showRegister(store: store)).eraseToAnyPublisher()
        
    case .openForgot:
        return Just(.showForgot).eraseToAnyPublisher()
        
    case let .clickLogin(user):
        return mutationLogin(user, packages: packages).withStatus(start: .progressLoginStatus(.start), finish: .progressLoginStatus(.stop))

    case let .check(field, input):
        return mutatationDefineFieldStatus(field, input).eraseToAnyPublisher()
    
    case let .click(field):
        return Just(.registrationCredentials((credentials: field, status: .undefined))).eraseToAnyPublisher()

    case .cleanError:
        return Just(.setErrorMessage(nil)).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationLogin(_ user: LoginCredentials, packages: LoginPackages) -> AnyPublisher<LoginMutation, Never> {
        packages.loginService.login(with: user)
            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
            .map { LoginMutation.login(user: user) }
            .catch { Just(LoginMutation.setErrorMessage($0)) }
            .eraseToAnyPublisher()
    }

    func mutatationDefineFieldStatus(_ field: LoginCredentialsField, _ input: String) -> AnyPublisher<LoginMutation, Never> {
        Just({
            switch field {
            case .email:
                return LoginMutation.registrationCredentials((credentials: .email, status: input.isEmail ? .valid : .unvalidWithMessage("Unvalid email format")))
            case .password:
                return LoginMutation.registrationCredentials((credentials: .password, status: input.passwordValidationMessage == nil ? .valid : .unvalidWithMessage(input.passwordValidationMessage!) ))
            }
        }()).eraseToAnyPublisher()
    }
             
}
