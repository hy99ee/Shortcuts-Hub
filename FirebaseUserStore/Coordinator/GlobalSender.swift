import Combine
import SwiftUI

class GlobalSender: TransitionSender {
    @ObservedObject var sessionService = SessionService.shared
    private var subscriptions = Set<AnyCancellable>()
    private lazy var isFirstOpenKey = "isFirstOpen"
    private lazy var isFirstOpen = !UserDefaults.standard.bool(forKey: isFirstOpenKey)
//    let isFirstOpen = true

    let transition = PassthroughSubject<GlobalLink, Never>()
    
    init() {
        sessionService.$state
            .map {
                switch $0 {
                case .loggedIn:
                    return GlobalLink.login
                case .loggedOut:
                    return GlobalLink.logout
                case .loading:
                    return GlobalLink.progress
                }
            }
            .flatMap {[weak self] state -> AnyPublisher<GlobalLink, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }

                let sessionState = Just(state).share().eraseToAnyPublisher()
                if case .login = state, self.isFirstOpen {
                    return Publishers.Merge(
                        sessionState,
                        Just(GlobalLink.promo)
                            .handleEvents(receiveOutput: { _ in UserDefaults.standard.set(false, forKey: self.isFirstOpenKey)})
                            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
                    ).eraseToAnyPublisher()
                }
                return sessionState
            }
            .print("++++++++++")
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.main)
            .subscribe(transition)
//            .sink(receiveValue: {
////                guard let self else { return }
//                self.transition.send($0)
//            })
            .store(in: &subscriptions)
    }
    deinit {
        print("+++++++ DEAD +++++")
    }
}
