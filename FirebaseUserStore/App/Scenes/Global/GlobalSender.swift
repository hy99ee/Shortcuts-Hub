import Combine
import SwiftUI

class GlobalSender: TransitionSender {
    @ObservedObject var sessionService = SessionService.shared
    let transition = PassthroughSubject<GlobalLink, Never>()

    let globalPackages = GlobalStoreRepository.shared

    private lazy var isFirstOpenKey = "isFirstOpen"
    private lazy var isFirstOpen = UserDefaults.standard.bool(forKey: isFirstOpenKey)
    
    var subscriptions = Set<AnyCancellable>()
    
    init() {
        sessionService.$state
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: {[weak self] in
                self?.globalPackages.libraryStore.updatedSessionStatus($0)
            })
            .map {
                switch $0 {
                case .loggedIn: return GlobalLink.library
                case .loggedOut: return GlobalLink.gallery
                case .loading: return GlobalLink.progress
                }
            }
//            .flatMap { [weak self] state -> AnyPublisher<GlobalLink, Never> in
//                guard let self else { return Empty().eraseToAnyPublisher() }
//
//                let sessionState = Just(state).share().eraseToAnyPublisher()
//                if case GlobalLink.gallery = state {
//                    return Publishers.Merge(
//                        sessionState,
//                        Just(GlobalLink.promo)
//                            .handleEvents(receiveOutput: { _ in
//                                self.isFirstOpen = false
//                                UserDefaults.standard.set(self.isFirstOpen, forKey: self.isFirstOpenKey)
//                            })
//                            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
//                    ).eraseToAnyPublisher()
//                }
//
//                return sessionState
//            }
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.main)
            .subscribe(transition)
            .store(in: &subscriptions)
    }

    func openCreate(last: GlobalLink) {
        transition.send(.create)
        transition.send(last)
    }
}
