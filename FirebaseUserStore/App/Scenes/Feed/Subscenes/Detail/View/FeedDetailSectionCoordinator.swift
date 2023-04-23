import SwiftUI
import Combine

enum FeedDetailLink: TransitionType {
    case open(_ item: Item)
    case error(_ error: Error)
    case close

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .open: hasher.combine(0)
        case .error: hasher.combine(1)
        case .close: hasher.combine(2)
        }
    }

    static func == (lhs: FeedDetailLink, rhs: FeedDetailLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct FeedDetailSectionCoordinator: CoordinatorType {
    @Binding private var parent: FeedLink?

    @State var path: NavigationPath = NavigationPath()
    @State var alert: FeedDetailLink?
    
    @State private var isOpen = false

    private var store: FeedDetailSectionStore
    let stateReceiver: AnyPublisher<FeedDetailLink, Never>

    init(store: FeedDetailSectionStore, parent: Binding<FeedLink?>) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
        self._parent = parent
    }

    var view: AnyView {
        AnyView(
            NavigationStack(path: $path) {
                ZStack {
                    Rectangle()
                        .fill(.thinMaterial)
                        .cornerRadius(isOpen ? 0 : 40)
                    
                    FeedDetailSectionView(store: store)
                        .transition(.identity)
                        .applyClose(closeBinding: $parent, .tollbar, animation: .spring().speed(1.3))
                }
                .navigationDestination(for: FeedDetailLink.self, destination: linkDestination)
            }
                .onAppear {
                    store.dispatch(.initDetail)
                    withAnimation(.spring()) {
                        isOpen = true
                    }
                }
        )
    }

    func transitionReceiver(_ link: FeedDetailLink) {
        switch link {
        case .open:
            path.append(link)
        case .error:
            alert = link
        case .close:
            withAnimation(.spring()) {
                parent = nil
            }
        }
    }

    @ViewBuilder private func linkDestination(link: FeedDetailLink) -> some View {
        switch link {
        case let .open(item):
            ItemDetailView(item: item)
        default:
            EmptyView()
        }
    }
}
