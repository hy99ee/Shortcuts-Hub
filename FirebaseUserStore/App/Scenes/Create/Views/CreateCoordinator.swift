import SwiftUI
import Combine
import SwiftUDF

enum CreateLink: TransitionType {
    case createFromAppleItem(_ item: AppleApiItem, linkFromUser: String)
    case itemCreated
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: CreateLink, rhs: CreateLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct CreateCoordinator: CoordinatorType {
    private var store: CreateStore

    @State var creatingItem: Item = Item(id: UUID(), userId: "", title: "", description: "", createdAt: Date())

    @State var path = NavigationPath()
    @State var alert: CreateLink?

    @State private var detents: Set<PresentationDetent> = [.medium]
    @State private var detent: PresentationDetent = .medium

    @Environment(\.presentationMode) var presentationMode

    let stateReceiver: AnyPublisher<CreateLink, Never>
    let rootView: CreateAppleLinkEnterView

    init(store: CreateStore) {
        self.store = store
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
        .presentationDetents(detents, selection: $detent)
        .presentationDragIndicator(.hidden)
    }

    func transitionReceiver(_ link: CreateLink) {
        switch link {
        case .createFromAppleItem:
            self.path.append(link)
        case .error:
            self.alert = link
        case .itemCreated:
            presentationMode.wrappedValue.dismiss()
        }
    }

    @ViewBuilder private func linkDestination(link: CreateLink) -> some View {
        switch link {
        case let .createFromAppleItem(item, link):
            CreateView(store: store, appleItem: item, originalLink: link)
                .onAppear {
                    setDetent(.large)
                }
                .onDisappear {
                    setDetent(.medium)
                }
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

    private func setDetent(_ detent: PresentationDetent) {
        detents.insert(detent)
        self.detent = detent
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            detents = [detent]
        }
    }
}
