import Foundation
import Combine
import SwiftUI

struct LoginDispatcher: DispatcherType {
    typealias MutationType = LoginMutation

    typealias EnvironmentPackagesType = LoginPackages
    typealias LoginServiceError = EnvironmentPackagesType.PackageLoginService.ServiceError
    typealias RegistrationServiceError = EnvironmentPackagesType.PackageRegistrationService.ServiceError
    typealias ForgotServiceError = EnvironmentPackagesType.PackageForgotService.ServiceError

    func dispatch(_ action: LoginAction, packages: EnvironmentPackagesType) -> AnyPublisher<MutationType, Never> {
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
    }
}

// MARK: - Mutations
extension LoginDispatcher {
    private func mutationLogin(_ user: LoginCredentials, packages: EnvironmentPackagesType) -> AnyPublisher<LoginMutation, Never> {
        loginPublisher(user, package: packages.loginService)
            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
            .map { LoginMutation.login(user: user) }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    private func mutationRegister(_ user: RegistrationCredentials, packages: EnvironmentPackagesType) -> AnyPublisher<LoginMutation, Never> {
        registerPublisher(user, package: packages.registrationService)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { LoginMutation.create(user: user) }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    private func mutationForgot(_ email: String, packages: EnvironmentPackagesType) -> AnyPublisher<LoginMutation, Never> {
        forgotPublisher(email, package: packages.forgotService)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { LoginMutation.closeForgot }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Publishers
extension LoginDispatcher {
    private func loginPublisher(_ user: LoginCredentials, package: LoginService) -> AnyPublisher<Void, LoginServiceError> {
        package.login(with: user)
            .map { _ -> () in }
            .eraseToAnyPublisher()
    }
    private func registerPublisher(_ user: RegistrationCredentials, package: RegistrationService) -> AnyPublisher<Void, RegistrationServiceError> {
        package.register(with: user)
            .eraseToAnyPublisher()
    }
    private func forgotPublisher(_ email: String, package: ForgotPasswordService) -> AnyPublisher<Void, ForgotServiceError> {
        package.sendPasswordResetRequest(to: email)
            .eraseToAnyPublisher()
    }
}
