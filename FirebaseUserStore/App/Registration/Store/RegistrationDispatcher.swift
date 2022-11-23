import Foundation
import Combine
import SwiftUI

struct RegistrationDispatcher<Service>: DispatcherType where Service: (RegistrationServiceType & EnvironmentType) {
    typealias MutationType = RegistrationMutation
    typealias ServiceEnvironment = Service
    typealias ServiceError = Service.ServiceError

    var environment: Service

    func dispatch(_ action: RegistrationAction) -> AnyPublisher<MutationType, Never> {
        switch action {
        case let .create(newUser):
            return mutationFetchItems(newUser).withStatus(start: RegistrationMutation.progressViewStatus(status: .start), finish: RegistrationMutation.progressViewStatus(status: .stop))

        case .mockAction:
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
    }
}

// MARK: - Mutations
extension RegistrationDispatcher {
    private func mutationFetchItems(_ user: RegistrationCredentials) -> AnyPublisher<RegistrationMutation, Never> {
        registerPublisher(user)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .map { RegistrationMutation.newUser(user: user) }
            .catch { Just(RegistrationMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Publishers
extension RegistrationDispatcher {
    private func registerPublisher(_ user: RegistrationCredentials) -> AnyPublisher<Void, ServiceError> {
        environment.register(with: user)
            .map { _ -> () in }
            .eraseToAnyPublisher()
    }
}
