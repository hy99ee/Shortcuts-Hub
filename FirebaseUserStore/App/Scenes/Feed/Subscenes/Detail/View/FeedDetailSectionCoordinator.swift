import SwiftUI
import Combine

struct FeedDetailSectionCoordinator: CoordinatorType {
    @Binding private var parent: FeedLink?
    @State private var isOpen = false

    private var store: FeedDetailSectionStore
    let stateReceiver: AnyPublisher<CloseTransition, Never>

    init(store: FeedDetailSectionStore, parent: Binding<FeedLink?>) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
        self._parent = parent
    }

    var view: AnyView {
        AnyView(
            ZStack {
                Rectangle()
                    .fill(.thinMaterial)
                    .cornerRadius(isOpen ? 0 : 40)
                
                FeedDetailSectionView(store: store)
                    .transition(.identity)
                    .applyClose(closeBinding: $parent, .tollbar, animation: .spring().speed(1.3))
                    .onAppear {
                        store.dispatch(.initDetail)
                        withAnimation(.spring()) {
                            isOpen = true
                        }
                    }
            }
        )
    }

    func transitionReceiver(_ link: CloseTransition) {
        withAnimation(.spring()) {
            parent = nil
        }
    }
}
