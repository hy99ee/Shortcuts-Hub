import Foundation
import Combine
import SwiftUI

struct LoginDispatcher<Login, Registration, Forgot>:
    DispatcherType where Login: LoginServiceType,
                         Registration: RegistrationServiceType,
                         Forgot: ForgotPasswordService {
    typealias MutationType = LoginMutation

    var loginService: Login
    var registrationService: Registration
    var forgotService: Forgot

    func dispatch(_ action: LoginAction) -> AnyPublisher<MutationType, Never> {
        switch action {
        case let .openRegister(store):
            return Just(LoginMutation.showRegister(store: store)).eraseToAnyPublisher()

        case let .openForgot(store):
            return Just(LoginMutation.showForgot(store: store)).eraseToAnyPublisher()

        case let .clickLogin(user):
            return mutationLogin(user).withStatus(start: LoginMutation.progressLoginStatus(.start), finish: LoginMutation.progressLoginStatus(.stop))

        case let .clickCreate(newUser):
            return mutationRegister(newUser).withStatus(start: LoginMutation.progressRegisterStatus(.start), finish: LoginMutation.progressRegisterStatus(.stop))

        case let .clickForgot(email):
            return mutationForgot(email).withStatus(start: LoginMutation.progressForgotStatus(.start), finish: LoginMutation.progressForgotStatus(.stop))

        case .mockAction:
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
    }
}

// MARK: - Mutations
extension LoginDispatcher {
    private func mutationLogin(_ user: LoginCredentials) -> AnyPublisher<LoginMutation, Never> {
        loginPublisher(user)
            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
            .map { LoginMutation.login(user: user) }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    private func mutationRegister(_ user: RegistrationCredentials) -> AnyPublisher<LoginMutation, Never> {
        registerPublisher(user)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { LoginMutation.create(user: user) }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    private func mutationForgot(_ email: String) -> AnyPublisher<LoginMutation, Never> {
        forgotPublisher(email)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { LoginMutation.closeForgot }
            .catch { Just(LoginMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Publishers
extension LoginDispatcher {
    private func loginPublisher(_ user: LoginCredentials) -> AnyPublisher<Void, Login.ServiceError> {
        loginService.login(with: user)
            .map { _ -> () in }
            .eraseToAnyPublisher()
    }
    private func registerPublisher(_ user: RegistrationCredentials) -> AnyPublisher<Void, Registration.ServiceError> {
        registrationService.register(with: user)
            .eraseToAnyPublisher()
    }
    private func forgotPublisher(_ email: String) -> AnyPublisher<Void, Forgot.ServiceError> {
        forgotService.sendPasswordResetRequest(to: email)
            .eraseToAnyPublisher()
    }
}
