import SwiftUI
import Combine

struct CreateCoordinator: CoordinatorType {
    @Environment(\.presentationMode) var presentationMode
    @Binding var id: UUID?

    private var store: CreateStore
    let stateReceiver: AnyPublisher<CloseTransition, Never>

    init(store: CreateStore, newId id: Binding<UUID?>) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
        self._id = id
    }

    var view: AnyView {
        AnyView(CreateView(store: store, id: $id))
            
    }

    func transitionReceiver(_ link: CloseTransition) {
        presentationMode.wrappedValue.dismiss()
    }
}
