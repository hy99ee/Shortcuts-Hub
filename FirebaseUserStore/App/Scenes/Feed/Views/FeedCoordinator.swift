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

    @State private var clickedSection: IdsSection?
    @State private var previousClickedSection: IdsSection?

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
                if clickedSection == nil {
                    Color(UIColor.systemBackground)
                        .transition( .asymmetric(insertion: .identity, removal: .opacity).animation(.spring().speed(2)))
                        .ignoresSafeArea()
                }

                if clickedSection == nil {
                    FeedView(
                        store: store,
                        clickedSection: $clickedSection,
                        previousClickedSection: $previousClickedSection
                    )
                    .transition(.scale(scale: 1.1).animation(.spring().speed(2)))
                    .environmentObject(NamespaceWrapper(open))
                    .padding([.horizontal], 24)
                    .animationAdapted(animationDuration: 1)
                }

                if clickedSection != nil {
                    FeedDetailSectionCoordinator(
                        store: store.packages.makeFeedSectionDetailStore(clickedSection!),
                        path: $path,
                        parent: $clickedSection
                    )
                    .environmentObject(NamespaceWrapper(open))
                    .transition(.offset(y: -10).animation(.spring().speed(2)))
                }
            }

        }
    }

    func transitionReceiver(_ link: FeedLink) {
        switch link {
        case .section:
            if case let FeedLink.section(section) = link {
                withAnimation(.spring().speed(1.2)) {
                    clickedSection = section
                }
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

struct FeedCoordinator_Preview: PreviewProvider {
    @Namespace static var open
    private static var store = _FeedPackages().makeFeedSectionDetailStore(IdsSection.mockSections.first!)

    static var previews: some View {
        FeedCoordinator(
            store: FeedStore(
                state: FeedState(),
                dispatcher: feedDispatcher,
                reducer: feedReducer,
                packages: FeedPackages()
            )
        )
    }
}
