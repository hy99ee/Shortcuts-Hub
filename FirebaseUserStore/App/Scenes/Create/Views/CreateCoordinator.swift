import SwiftUI
import Combine

enum CreateLink: TransitionType {
    case createFromAppleItem(_ item: AppleApiItem, linkFromUser: String)
    case itemCreated(_ item: Item)
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .createFromAppleItem:
            hasher.combine(0)
        case .error:
            hasher.combine(1)
        case .itemCreated:
            hasher.combine(2)
        }
    }

    static func == (lhs: CreateLink, rhs: CreateLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct CreateCoordinator: CoordinatorType {
    private var store: CreateStore
    @Binding var id: UUID?

    @State var creatingItem: Item = Item(id: UUID(), userId: "", title: "", description: "", createdAt: Date())

    @State var path = NavigationPath()
    @State var sheet: CreateLink?
    @State var alert: CreateLink?

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
                    .alert(item: $alert, content: alertContent)
            }
            .navigationDestination(for: CreateLink.self, destination: linkDestination)
        }
    }

    func transitionReceiver(_ link: CreateLink) {
        switch link {
        case .createFromAppleItem:
            self.path.append(link)
        case .error:
            self.alert = link
        case let .itemCreated(item):
            id = item.id
            presentationMode.wrappedValue.dismiss()
        }
    }

    @ViewBuilder private func linkDestination(link: CreateLink) -> some View {
        switch link {
        case let .createFromAppleItem(item, link):
            CreateView(store: store, appleItem: item, originalLink: link)
        default:
            EmptyView()
        }
    }

    private func alertContent(link: CreateLink) -> Alert {
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
