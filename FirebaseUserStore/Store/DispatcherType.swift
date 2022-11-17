import Combine

protocol DispatcherType {
    associatedtype ActionType: Action
    associatedtype MutationType: Mutation

    func dispatch(_ action: ActionType) -> AnyPublisher<MutationType, Never>
}
