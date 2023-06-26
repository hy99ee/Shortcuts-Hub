import Combine
import SwiftUI

class GlobalSender: TransitionSender {
    @StateObject var sessionService = SessionService.shared
    let transition = PassthroughSubject<GlobalLink, Never>()

    let globalPackages = GlobalStoreRepository.shared

    private lazy var isFirstOpenKey = "isFirstOpen"
    private lazy var isFirstOpen = UserDefaults.standard.bool(forKey: isFirstOpenKey)
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        sessionService.$state
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: {[weak self] in
                self?.globalPackages.libraryStore.updatedSessionStatus($0)
                self?.globalPackages.savedStore.updatedSessionStatus($0)
            })
            .map {
                switch $0 {
                case .loggedIn: return GlobalLink.gallery
                case .loggedOut: return GlobalLink.gallery
                case .loading: return GlobalLink.progress
                }
            }
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.main)
            .subscribe(transition)
            .store(in: &subscriptions)

        sessionService.$databaseMutation
            .compactMap { $0 }
            .sink {[weak self] in
                switch $0 {
                case let .add(item):
                    self?.globalPackages.savedStore.dispatch(.addItem(item))

                case let .remove(item):
                    self?.globalPackages.savedStore.dispatch(.removeItem(item))
                }
            }
            .store(in: &subscriptions)

        sessionService.$firestoreMutation
            .compactMap { $0 }
            .sink {[weak self] in
                switch $0 {
                case let .add(item):
                    self?.globalPackages.libraryStore.dispatch(.addItem(item))

                case let .remove(item):
                    self?.globalPackages.libraryStore.dispatch(.removeItem(item))
                }
            }
            .store(in: &subscriptions)
    }

    func openCreate(last: GlobalLink) {
        transition.send(.create)
        transition.send(last)
    }
}
