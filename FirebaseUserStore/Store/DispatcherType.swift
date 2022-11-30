import Combine

protocol DispatcherType {
    associatedtype ActionType: Action
    associatedtype MutationType: Mutation
    associatedtype EnvironmentPackagesType: EnvironmentPackages

    func dispatch(_ action: ActionType, packages: EnvironmentPackagesType) -> AnyPublisher<MutationType, Never>
}
