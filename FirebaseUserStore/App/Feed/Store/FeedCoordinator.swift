import Foundation
import SwiftUI
import Combine

enum FeedLink: TransitionType {
    case about(_ data: AboutViewData)
    case detail(_ item: Item)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .about:
            hasher.combine(0)
        case .detail:
            hasher.combine(1)
        }
    }

    static func == (lhs: FeedLink, rhs: FeedLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

enum TransitionState<T: TransitionType> {
    case start
    case appendPath(_ link: T)
    case sheet(_ link: T)
    case fullcover(_ link: T)
}

protocol CoordinatorType: View {
    associatedtype Link: TransitionType

    var stateReceiver: AnyPublisher<Link, Never> { get }
    var path: NavigationPath { get set }
    var sheet: Link? { get }
    var fullcover: Link? { get }


    var view: AnyView { get }
    
    func transitionReceiver(_ link: Link)
}

extension CoordinatorType {
    var body: some View {
        view
        .onReceive(stateReceiver) {
            transitionReceiver($0)
        }
    }
}

struct FeedCoordinator: CoordinatorType {
    @State var path = NavigationPath()
    @State var sheet: FeedLink?
    var fullcover: FeedLink?

    private var store: FeedStore
    private var root: FeedView
    let stateReceiver: AnyPublisher<FeedLink, Never>

    init(store: FeedStore) {
        self.store = store
        self.root = FeedView(store: store)
        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(_view)
    }
    @ViewBuilder private var _view: some View {
        NavigationStack(path: $path) {
            ZStack {
                root
                    .sheet(item: $sheet, content: sheetContent)
            }
            .navigationDestination(for: FeedLink.self, destination: linkDestination)
        }
    }

    func transitionReceiver(_ link: FeedLink) {
        switch link {
        case .about:
            self.sheet = link
        case .detail:
            self.path.append(link)
        }
    }

    @ViewBuilder private func linkDestination(link: FeedLink) -> some View {
        switch link {
        case let .detail(item):
            Text(item.title)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func sheetContent(link: FeedLink) -> some View {
        switch link {
        case let .about(data):
            AboutView(aboutData: data).presentationDetents([.height(200), .medium])
        default:
            EmptyView()
        }
    }
}
