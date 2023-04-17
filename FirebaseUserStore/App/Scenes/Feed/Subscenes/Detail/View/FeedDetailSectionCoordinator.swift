import SwiftUI
import Combine

struct FeedDetailSectionCoordinator: CoordinatorType {
    @Binding private var parent: FeedLink?

    private var store: FeedDetailSectionStore
    let stateReceiver: AnyPublisher<CloseTransition, Never>

    init(store: FeedDetailSectionStore, parent: Binding<FeedLink?>) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
        self._parent = parent
    }

    var view: AnyView {
        AnyView(
            FeedDetailSectionView(store: store)
                .applyClose(closeBinding: $parent, .tollbar, animation: .spring())
        )
    }

    func transitionReceiver(_ link: CloseTransition) {
        withAnimation(.spring()) {
            parent = nil
        }
    }
}
