import SwiftUI
import Combine

struct CreateCoordinator: CoordinatorType {
    @Environment(\.presentationMode) var presentationMode

    private var store: CreateStore
    let stateReceiver: AnyPublisher<CloseTransition, Never>

    init(store: CreateStore) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }

    var view: AnyView {
        AnyView(CreateView(store: store))
    }

    func transitionReceiver(_ link: CloseTransition) {
        presentationMode.wrappedValue.dismiss()
    }
}
