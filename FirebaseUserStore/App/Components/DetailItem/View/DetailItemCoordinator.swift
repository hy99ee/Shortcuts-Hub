import SwiftUI
import Combine

struct DetailItemCoordinator: CoordinatorType {
    @State var alert: ErrorTransition?
    let stateReceiver: AnyPublisher<ErrorTransition, Never>

    @Binding private var itemFromParent: Item
    private var store: DetailItemStore

    init(item: Binding<Item>) {
        self.store = DetailItemStore(
            state: DetailItemState(item: item.wrappedValue),
            dispatcher: feedDetailItemDispatcher,
            reducer: feedDetailItemReducer,
            packages: DetailItemPackages(),
            middlewares: [DetailItemStore.middlewareOperation]
        )

        self._itemFromParent = item
        self.stateReceiver = store.transition.print("TRANSITION GET").eraseToAnyPublisher()
    }

    var view: AnyView {
        AnyView(
            ItemDetailView(store: store, updateItem: $itemFromParent)
                .alert(item: $alert, content: alertContent)
        )
    }

    func transitionReceiver(_ link: ErrorTransition) {
        switch link {
        case .error:
            alert = link
        }
    }

    private func alertContent(link: ErrorTransition) -> Alert {
        switch link {
        case let .error(error):
            return Alert(title: Text("Something went wrong"),
                  message: Text(error.localizedDescription),
                  dismissButton: .default(Text("OK")))
        }
    }
}
