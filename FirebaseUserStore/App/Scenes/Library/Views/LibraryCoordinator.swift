import Foundation
import SwiftUI
import Combine

enum LibraryLink: TransitionType {
    case login
    case about(_ data: AboutViewData)
    case detail(_ item: Item)
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .login:
            hasher.combine(0)
        case .about:
            hasher.combine(1)
        case .detail:
            hasher.combine(2)
        case .error:
            hasher.combine(3)
        }
    }

    static func == (lhs: LibraryLink, rhs: LibraryLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct LibraryCoordinator: CoordinatorType {
    @State var path = NavigationPath()
    @State var fullcover: LibraryLink?
    @State var sheet: LibraryLink?
    @State var alert: LibraryLink?

    private var store: LibraryStore
    private var rootView: LibraryView
    let stateReceiver: AnyPublisher<LibraryLink, Never>

    init(store: LibraryStore) {
        self.store = store
        self.rootView = LibraryView(store: store)
        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(_view)
    }

    @ViewBuilder private var _view: some View {
        NavigationStack(path: $path) {
            ZStack {
                rootView
                    .fullScreenCover(item: $fullcover, content: fullcoverContent)
                    .sheet(item: $sheet, content: sheetContent)
                    .alert(item: $alert, content: alertContent)
            }
            .navigationDestination(for: LibraryLink.self, destination: linkDestination)
        }
    }

    func transitionReceiver(_ link: LibraryLink) {
        switch link {
        case .login:
            self.fullcover = link
        case .about:
            self.path.append(link)
        case .detail:
            self.path.append(link)
        case .error:
            self.alert = link
        }
    }

    @ViewBuilder private func linkDestination(link: LibraryLink) -> some View {
        switch link {
        case let .about(data):
            AboutView(aboutData: data)
        case let .detail(item):
            DetailItemCoordinator(
                item: Binding(get: {
                    store.state.items.first(where: { $0 == item })!
                }, set: { newItem in
                    print("IS SAVED ITEM FROM SECTION: \(newItem)")
//                    if let index = store.state.itemsFromSection.firstIndex(where: { $0 == item }) {
//                        store.state.itemsFromSection[index] = newItem
//                    }
                })
            )
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder private func fullcoverContent(link: LibraryLink) -> some View {
        switch link {
        case .login:
            LoginCoordinator(store: store.packages.loginStore, parent: $fullcover)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func sheetContent(link: LibraryLink) -> some View {
        switch link {
        default:
            EmptyView()
        }
    }

    private func alertContent(link: LibraryLink) -> Alert {
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

