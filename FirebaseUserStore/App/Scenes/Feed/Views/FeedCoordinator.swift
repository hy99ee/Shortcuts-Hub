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
        case .section:
            hasher.combine(0)
        case .error:
            hasher.combine(1)
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
        NavigationStack(path: $path) {
            ZStack {
                rootView
                    .alert(item: $alert, content: alertContent)
            }
            .navigationDestination(for: FeedLink.self, destination: linkDestination)
        }
    }

    @ViewBuilder private var rootView: some View {
        if custom == nil {
            feedView
                .transition(
                    .scale(scale: 1.2, anchor: .top)
                    .combined(with: .opacity)
                )
                .environmentObject(NamespaceWrapper(open))
                .padding(custom == nil ? 15 : 0)
                .animationAdapted(animationDuration: 1)
        } else {
            if case let custom, let custom {
                if case let FeedLink.section(section) = custom {
                    DetailSectionView(section: section, onClose: {
                        withAnimation(
                            .interactiveSpring(
                                response: 0.6,
                                dampingFraction: 0.7,
                                blendDuration: 0.7
                            )
                        ) {
                            self.custom = nil
                        }
                    })
                    .matchedGeometryEffect(id: section.id, in: open)
                    .environmentObject(NamespaceWrapper(open))
                    .transition(
                        .scale(scale: 0.8, anchor: .top)
                        .combined(with: .opacity)
                    )
                    .animationAdapted(animationDuration: 0.8)
                }
            }
        }
    }

    func transitionReceiver(_ link: FeedLink) {
        switch link {
        case .section:
            withAnimation(
                .interactiveSpring(
                    response: 0.6,
                    dampingFraction: 0.7,
                    blendDuration: 0.7
                )
            ) {
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
