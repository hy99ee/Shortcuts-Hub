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
    @State var path = NavigationPath()
    @State var alert: FeedLink?
    @State var custom: FeedLink?

    @Namespace var open

    private let store: FeedStore
    private let feedView: FeedView
    let stateReceiver: AnyPublisher<FeedLink, Never>

    init(store: FeedStore) {
        self.store = store
        self.feedView = FeedView(store: store)
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
        NavigationStack(path: $path) {
            ZStack {
                feedView
                    .environmentObject(NamespaceWrapper(open))
                    .padding([.horizontal], custom == nil ? 24 : 14)
                    .navigationDestination(for: FeedLink.self, destination: linkDestination)

                if custom != nil {
                    BlurView(style: .systemThickMaterial)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                
                if case let custom, let custom {
                    if case let FeedLink.section(section) = custom {
                        FeedDetailSectionCoordinator(
                            store: store.packages.makeFeedSectionDetailStore(section),
                            path: $path,
                            parent: self.$custom
                        )
                        .environmentObject(NamespaceWrapper(open))
                        .background {
//                            Color.white
//                                .opacity(0.9)
//                                .blur(radius: 100)
                        }
                        .transition(.asymmetric(insertion: .identity, removal: .identity))
//                        .transition(.asymmetric(insertion: .scale(scale: 0.95, anchor: .top).animation(.spring().speed(0.8)), removal: .identity))
                    }
                }
            }
        }
    }

    func transitionReceiver(_ link: FeedLink) {
        switch link {
        case .section:
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.6)) {
                custom = link
            } 
            
        case .error:
            self.alert = link
        }
    }

    @ViewBuilder private func linkDestination(link: FeedLink) -> some View {
        switch link {
        case let .section(section):
            Text(section.title)
        default:
            EmptyView()
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
