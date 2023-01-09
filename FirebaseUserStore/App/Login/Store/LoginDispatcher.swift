import Foundation
import Combine
import SwiftUI

let loginDispatcher: DispatcherType<LoginAction, LoginMutation, LoginPackages> = { action, packages in
    switch action {
    case let .openRegister(store):
        return Just(LoginMutation.showRegister(store: store)).eraseToAnyPublisher()
        
    case .openForgot:
        return Just(LoginMutation.showForgot).eraseToAnyPublisher()
        
    case let .clickLogin(user):
        return mutationLogin(user, packages: packages).withStatus(start: LoginMutation.progressLoginStatus(.start), finish: LoginMutation.progressLoginStatus(.stop))
        
    case let .clickCreate(newUser):
        return mutationRegister(newUser, packages: packages).withStatus(start: LoginMutation.progressRegisterStatus(.start), finish: LoginMutation.progressRegisterStatus(.stop))

    case .mockAction:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationLogin(_ user: LoginCredentials, packages: LoginPackages) -> AnyPublisher<LoginMutation, Never> {
        loginPublisher(user, package: packages.loginService)
            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
            .map { LoginMutation.login(user: user) }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    
    func mutationRegister(_ user: RegistrationCredentials, packages: LoginPackages) -> AnyPublisher<LoginMutation, Never> {
        registerPublisher(user, package: packages.registrationService)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { LoginMutation.create(user: user) }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    // MARK: - Publishers
    func loginPublisher(_ user: LoginCredentials, package: LoginService) -> AnyPublisher<Void, LoginServiceError> {
        package.login(with: user)
            .map { _ -> () in }
            .eraseToAnyPublisher()
    }
    func registerPublisher(_ user: RegistrationCredentials, package: RegistrationService) -> AnyPublisher<Void, RegistrationServiceError> {
        package.register(with: user)
            .eraseToAnyPublisher()
    }
}
