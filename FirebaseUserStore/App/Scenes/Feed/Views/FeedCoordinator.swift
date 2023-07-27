import Combine
import SwiftUDF
import SwiftUI

enum FeedLink: TransitionType {
    case section(_ section: IdsSection)
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: FeedLink, rhs: FeedLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class NamespaceWrapper: ObservableObject {
    var namespace: Namespace.ID

    init(_ namespace: Namespace.ID) {
        self.namespace = namespace
    }
}

struct FeedCoordinator: CoordinatorType {
    @ObservedObject private var store: FeedStore

    @State var path = NavigationPath()
    @State var alert: FeedLink?
    @State var custom: FeedLink?

    @State private var isShowBlur = false

    @Namespace var open

    let stateReceiver: AnyPublisher<FeedLink, Never>

    init(store: FeedStore) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(_view)
    }

    @ViewBuilder private var _view: some View {
        rootView
            .alert(item: $alert, content: alertContent)
    }

    @ViewBuilder private var rootView: some View {
        NavigationStack {
            ZStack {
                FeedView(store: store)
                    .environmentObject(NamespaceWrapper(open))
                    .padding([.horizontal], 24)

                if case let custom, let custom {
                    if case let FeedLink.section(section) = custom {
                        FeedDetailSectionCoordinator(
                            store: store.packages.makeFeedSectionDetailStore(section),
                            path: $path,
                            parent: self.$custom
                        )
                        .environmentObject(NamespaceWrapper(open))
                        .transition(.identity)
                        .zIndex(100)
//                        .animation(.linear, value: self.custom)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    func transitionReceiver(_ link: FeedLink) {
        switch link {
        case .section:
            withAnimation(.easeOut.speed(1.2)) {
                custom = link
            } 

        case .error:
            self.alert = link
        }
    }

    private func alertContent(link: FeedLink) -> Alert {
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

extension FeedCoordinator: Equatable {
    static func == (lhs: FeedCoordinator, rhs: FeedCoordinator) -> Bool {
        lhs.store.state == rhs.store.state
    }


}
