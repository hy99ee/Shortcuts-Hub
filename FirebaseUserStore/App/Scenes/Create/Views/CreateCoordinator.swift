import SwiftUI
import Combine

enum CreateLink: TransitionType {
    case createFromAppleItem(_ item: AppleApiItem)
    case close

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .createFromAppleItem:
            hasher.combine(0)
        case .close:
            hasher.combine(1)
        }
    }

    static func == (lhs: CreateLink, rhs: CreateLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct CreateCoordinator: CoordinatorType {
    private var store: CreateStore
    @Binding var id: UUID?

    @State var path = NavigationPath()
    @Environment(\.presentationMode) var presentationMode

    let stateReceiver: AnyPublisher<CreateLink, Never>
    let rootView: CreateAppleLinkEnterView

    init(store: CreateStore, newId id: Binding<UUID?>) {
        self.store = store
        self._id = id
        self.stateReceiver = store.transition.eraseToAnyPublisher()
        self.rootView = CreateAppleLinkEnterView(store: store)
    }

    var view: AnyView {
        AnyView(_view)
    }

    @ViewBuilder private var _view: some View {
        NavigationStack(path: $path) {
            VStack {
                rootView
            }
            .navigationDestination(for: CreateLink.self, destination: linkDestination)
        }
    }

    func transitionReceiver(_ link: CreateLink) {
        switch link {
        case .createFromAppleItem:
            self.path.append(link)
        case .close:
            presentationMode.wrappedValue.dismiss()
        }
    }

    @ViewBuilder private func linkDestination(link: CreateLink) -> some View {
        switch link {
        case let .createFromAppleItem(item):
            CreateView(store: store, initialItem: item, id: $id)
        default:
            EmptyView()
        }
    }
}
