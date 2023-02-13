import SwiftUI
import Combine

struct ForgotCoordinator: CoordinatorType {
    @Binding private var parent: LoginLink?

    private var store: ForgotStore
    let stateReceiver: AnyPublisher<CloseTransition, Never>

    init(store: ForgotStore, parent: Binding<LoginLink?>) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
        self._parent = parent
    }

    var view: AnyView {
        AnyView(ForgotPasswordView(store: store))
    }

    func transitionReceiver(_ link: CloseTransition) {
        parent = nil
    }
}
