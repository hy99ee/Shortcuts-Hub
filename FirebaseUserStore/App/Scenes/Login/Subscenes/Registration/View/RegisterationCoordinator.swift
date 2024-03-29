import Combine
import SwiftUDF
import SwiftUI

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
        AnyView(
            RegisterView(store: store)
                .onAppear { store.reinit() }
        )
    }

    func transitionReceiver(_ link: CloseTransition) {
        parent = nil
    }
}
