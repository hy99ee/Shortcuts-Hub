import Foundation
import Combine
import SwiftUI

let forgotDispatcher: DispatcherType<ForgotAction, ForgotMutation, ForgotPackages> = { action, packages in
    switch action {
    case let .clickForgot(email):
        return mutationForgot(email, packages: packages).withStatus(start: ForgotMutation.progressForgotStatus(.start), finish: ForgotMutation.progressForgotStatus(.stop))
    case .clickEmailField:
        return Just(ForgotMutation.validEmailField).eraseToAnyPublisher()
    }

    func mutationForgot(_ email: String, packages: ForgotPackages) -> AnyPublisher<ForgotMutation, Never> {
        packages.forgotService.sendPasswordResetRequest(to: email)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { ForgotMutation.close }
            .catch { _ in Just(ForgotMutation.error) }
            .eraseToAnyPublisher()
    }
}
