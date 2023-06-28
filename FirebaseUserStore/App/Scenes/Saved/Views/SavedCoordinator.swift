import Combine
import SwiftUDF
import SwiftUI

enum SavedLink: TransitionType {
    case detail(_ item: Item)
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: SavedLink, rhs: SavedLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct SavedCoordinator: CoordinatorType {
    @State var path = NavigationPath()
    @State var sheet: SavedLink?
    @State var alert: SavedLink?

    private var store: SavedStore
    private var rootView: SavedView
    let stateReceiver: AnyPublisher<SavedLink, Never>

    init(store: SavedStore) {
        self.store = store
        self.rootView = SavedView(store: store)
        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(_view)
    }

    @ViewBuilder private var _view: some View {
        NavigationStack(path: $path) {
            ZStack {
                rootView
                    .sheet(item: $sheet, content: sheetContent)
                    .alert(item: $alert, content: alertContent)
            }
            .navigationDestination(for: SavedLink.self, destination: linkDestination)
        }
    }

    func transitionReceiver(_ link: SavedLink) {
        switch link {
        case .detail:
            self.path.append(link)
        case .error:
            self.alert = link
        }
    }

    @ViewBuilder private func linkDestination(link: SavedLink) -> some View {
        switch link {
        case let .detail(item):
            DetailItemCoordinator(item: item)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func sheetContent(link: SavedLink) -> some View {
        switch link {
        default:
            EmptyView()
        }
    }

    private func alertContent(link: SavedLink) -> Alert {
        switch link {
        case let .error(error):
            return Alert(title: Text("Something went wrong"),
                  message: Text(error.localizedDescription),
                  dismissButton: .default(Text("OK")))
        default:
            return Alert(title: Text(""))
        }
    }
}
