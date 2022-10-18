import Combine

protocol DispatcherType {
    associatedtype ActionType: Action
    associatedtype MutationType: Mutation

    func dispatch(action: ActionType) -> AnyPublisher<MutationType, Never>
}
