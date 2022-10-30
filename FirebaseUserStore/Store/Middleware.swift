import Foundation
import Combine

//protocol MiddlewarerType {
////    associatedtype MiddlewareType: Middl
//}

typealias _MiddlewareStore = MiddlewareStore
final class MiddlewareStore<StoreState, StoreAction> where StoreState: StateType, StoreAction: Action {
    enum MiddlewareRedispatch: Error {
        case redispatch(action: StoreAction)
    }

    typealias Middleware = (StoreState, StoreAction) -> AnyPublisher<StoreAction, MiddlewareRedispatch>
    
//    let input: PassthroughSubject<(StoreState, Action), Never> = .init()
    let output: PassthroughSubject<StoreAction, MiddlewareRedispatch> = .init()

    private var middlewares: [Middleware]
    private var anyCancellables: Set<AnyCancellable> = []

    init(middlewares: [Middleware]) {
        self.middlewares = middlewares
    }

    func dispatch(state: StoreState, action: StoreAction) -> Self {
        middlewares.publisher
            .flatMap { $0(state, action) }
            .sink(receiveCompletion: {[unowned self] in
                switch $0 {
                case .finished: self.output.send(action)
                case .failure(.redispatch(action: let action)):
                    self.middlewares = []
                    print("Redispatch with action: \(action)")
                    self.output.send(completion: .failure(.redispatch(action: action)))
                }
            }, receiveValue: { _ in })
            .store(in: &anyCancellables)

        return self
    }
}
