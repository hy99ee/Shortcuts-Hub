import Foundation
import SwiftUI
import Combine

enum FeedLink: TransitionType {
    case section(_ section: IdsSection)
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .section: hasher.combine(0)
        case .error: hasher.combine(1)
        }
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
        ZStack {
            NavigationStack(path: $path) {
                feedView
                    .environmentObject(NamespaceWrapper(open))
                    .padding([.horizontal], custom == nil ? 24 : 0)
                    .disabled(custom != nil)
                    .navigationDestination(for: FeedLink.self, destination: linkDestination)
            }
            
                if case let custom, let custom {
                    if case let FeedLink.section(section) = custom {
                        FeedDetailSectionCoordinator(
                            store: store.packages.makeFeedSectionDetailStore(section),
                            parent: self.$custom
                        )
                        .matchedGeometryEffect(id: section.id, in: open, anchor: .top)
                        .environmentObject(NamespaceWrapper(open))
                        .animationAdapted(animationDuration: 0.7)
                        .transition(.asymmetric(insertion: .scale(scale: 0.95), removal: .identity))
                    }
                }
        }
    }

    func transitionReceiver(_ link: FeedLink) {
        switch link {
        case .section:
            withAnimation(.spring().speed(1.3)) {
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
