import SwiftUI
import Combine

struct RegisterationCoordinator: CoordinatorType {
    @Binding private var parent: LibraryLink?

    private var store: RegisterationStore
    let stateReceiver: AnyPublisher<CloseTransition, Never>

    init(store: RegisterationStore, parent: Binding<LibraryLink?>) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
        self._parent = parent
    }

    var view: AnyView {
        AnyView(RegisterView(store: store))
    }

    func transitionReceiver(_ link: CloseTransition) {
//        store.reinit()
        parent = nil
    }
}
