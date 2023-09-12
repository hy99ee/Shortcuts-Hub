import Combine
import SwiftUDF
import SwiftUI

let forgotDispatcher: DispatcherType<ForgotAction, ForgotMutation, ForgotPackages> = { action, packages in
    switch action {
    case let .clickForgot(email):
        return mutationForgot(email, packages: packages).withStatus(start: ForgotMutation.progressForgotStatus(.start), finish: ForgotMutation.progressForgotStatus(.stop))
    case .clickEmailField:
        return Just(ForgotMutation.emailFieldStatus(.undefined)).eraseToAnyPublisher()
    case let .checkEmailField(input):
        return mutationDefineFieldStatus(input)
    }

    func mutationForgot(_ email: String, packages: ForgotPackages) -> AnyPublisher<ForgotMutation, Never> {
        packages.forgotService.sendPasswordResetRequest(to: email)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { ForgotMutation.close }
            .catch { error in Just(ForgotMutation.emailFieldStatus(.unvalidWithMessage(error.localizedDescription))) }
            .eraseToAnyPublisher()
    }

    func mutationDefineFieldStatus(_ input: String) -> AnyPublisher<ForgotMutation, Never> {
        Just(ForgotMutation.emailFieldStatus(input.isEmail ? .valid : .unvalidWithMessage("Unvalid email format"))).eraseToAnyPublisher()
    }
}
