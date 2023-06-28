import Combine
import SwiftUDF
import SwiftUI

struct DetailItemCoordinator: CoordinatorType {
    @State var alert: ErrorTransition?
    let stateReceiver: AnyPublisher<ErrorTransition, Never>

    private var store: DetailItemStore

    init(item: Item) {
        self.store = DetailItemStore(
            state: DetailItemState(item: item),
            dispatcher: feedDetailItemDispatcher,
            reducer: feedDetailItemReducer,
            packages: DetailItemPackages(),
            middlewares: [DetailItemStore.middlewareOperation]
        )

        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }

    var view: AnyView {
        AnyView(
            ItemDetailView(store: store)
                .alert(item: $alert, content: alertContent)
                .toolbar(.hidden, for: .tabBar)
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
