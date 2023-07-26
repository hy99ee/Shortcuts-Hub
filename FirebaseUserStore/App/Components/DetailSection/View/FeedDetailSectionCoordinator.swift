import Combine
import SwiftUDF
import SwiftUI

enum FeedDetailLink: TransitionType {
    case open(_ item: Item)
    case error(_ error: Error)
    case close

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: FeedDetailLink, rhs: FeedDetailLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct FeedDetailSectionCoordinator: CoordinatorType {
    @Binding private var parent: FeedLink?
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    @Binding var path: NavigationPath
    @State var alert: FeedDetailLink?

    private var store: FeedDetailSectionStore!
    let stateReceiver: AnyPublisher<FeedDetailLink, Never>

    init(store: FeedDetailSectionStore, path: Binding<NavigationPath>, parent: Binding<FeedLink?>) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
        self._path = path
        self._parent = parent
    }

    var view: AnyView {
        AnyView(
            NavigationStack(path: $path) {
                FeedDetailSectionView(store: store)
                    .environmentObject(NamespaceWrapper(namespaceWrapper.namespace))
                    .navigationDestination(for: FeedDetailLink.self, destination: linkDestination)
            }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        store.dispatch(.initDetail)
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .tabBar)
        )
    }

    func transitionReceiver(_ link: FeedDetailLink) {
        switch link {
        case .open:
            path.append(link)
        case .error:
            alert = link
        case .close:
            withAnimation(.interactiveSpring(response: 0.33, dampingFraction: 0.6, blendDuration: 0.6).speed(0.85)) {
                parent = nil
            }
        }
    }

    @ViewBuilder private func linkDestination(link: FeedDetailLink) -> some View {
        switch link {
        case let .open(item):
            DetailItemCoordinator(item: item)
        default:
            EmptyView()
        }
    }
}
