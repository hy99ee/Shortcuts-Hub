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
    private let store: FeedDetailSectionStore
    @Binding private var parent: IdsSection?
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    @Binding var path: NavigationPath
    @State var alert: FeedDetailLink?

    let stateReceiver: AnyPublisher<FeedDetailLink, Never>

    init(store: FeedDetailSectionStore, path: Binding<NavigationPath>, parent: Binding<IdsSection?>) {
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
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
            withAnimation(.pumping) {
                parent = nil
                store.reinit()
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

struct FeedDetailSectionCoordinator_Preview: PreviewProvider {
    @Namespace static var open
    private static var store = _FeedPackages().makeFeedSectionDetailStore(IdsSection.mockSections.first!)

    static var previews: some View {
        FeedDetailSectionCoordinator(
            store: store,
            path: .constant(NavigationPath()),
            parent: .constant(nil)
        )
        .environmentObject(NamespaceWrapper(FeedDetailSectionView_Preview.open))

    }
}
