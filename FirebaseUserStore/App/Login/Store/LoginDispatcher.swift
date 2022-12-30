import Foundation
import Combine
import SwiftUI

let loginDispatcher: DispatcherType<LoginAction, LoginMutation, LoginPackages> = { action, packages in
    switch action {
    case let .openRegister(store):
        return Just(LoginMutation.showRegister(store: store)).eraseToAnyPublisher()
        
    case let .openForgot(store):
        return Just(LoginMutation.showForgot(store: store)).eraseToAnyPublisher()
        
    case let .clickLogin(user):
        return mutationLogin(user, packages: packages).withStatus(start: LoginMutation.progressLoginStatus(.start), finish: LoginMutation.progressLoginStatus(.stop))
        
    case let .clickCreate(newUser):
        return mutationRegister(newUser, packages: packages).withStatus(start: LoginMutation.progressRegisterStatus(.start), finish: LoginMutation.progressRegisterStatus(.stop))
        
    case let .clickForgot(email):
        return mutationForgot(email, packages: packages).withStatus(start: LoginMutation.progressForgotStatus(.start), finish: LoginMutation.progressForgotStatus(.stop))
        
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
    
    func mutationForgot(_ email: String, packages: LoginPackages) -> AnyPublisher<LoginMutation, Never> {
        forgotPublisher(email, package: packages.forgotService)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { LoginMutation.closeForgot }
            .catch { _ in Just(LoginMutation.errorWithForgot) }
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
    func forgotPublisher(_ email: String, package: ForgotPasswordService) -> AnyPublisher<Void, ForgotServiceError> {
        package.sendPasswordResetRequest(to: email)
            .eraseToAnyPublisher()
    }
}
