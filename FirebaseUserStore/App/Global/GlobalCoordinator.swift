import SwiftUI
import Combine

enum GlobalLink: TransitionType {
    case gallery
    case create
    case library

    case progress

    case promo

    var id: String {
        switch self {
        case .gallery, .create, .library, .progress, .promo:
            return String(describing: self)
        }
    }
}


struct GlobalCoordinator: CoordinatorType {
    @State var sheet: GlobalLink?
    @State var root: GlobalLink = .progress
    @State private var lastSelected: GlobalLink = .gallery
    @State private var idForCreatingItem: UUID?

    let stateReceiver: AnyPublisher<GlobalLink, Never>
    private let sender: GlobalSender

    init() {
        sender = GlobalSender()
        stateReceiver = self.sender.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(rootView)
    }

    func transitionReceiver(_ link: GlobalLink) {
        switch link {
        case .gallery, .library:
            root = link
            lastSelected = link
        case .promo, .create:
            sheet = link
        case .progress:
            root = link
        }
    }

    @ViewBuilder private var rootView: some View {
        switch root {
        case .progress:
            HDotsProgress().scaleEffect(2)
        default:
            tabView.sheet(item: $sheet, content: sheetContent)
        }
    }
    
    private var tabView: some View {
        TabView(selection: $root) {
            gallery.tag(GlobalLink.gallery).tabItem { tabLabel(for: .gallery) }
            create.tag(GlobalLink.create).tabItem { tabLabel(for: .create) }
            library.tag(GlobalLink.library).tabItem { tabLabel(for: .library) }
        }
        .onChange(of: root) {
            if $0 == .create {
                sender.openCreate(last: lastSelected)
            }
        }
        .onChange(of: sheet) {
            if $0 == nil, let id = idForCreatingItem {
                sender.globalPackages.libraryStore.dispatch(.updateItem(id: id))
                idForCreatingItem = nil
            }
        }
        
    }

    private var gallery: some View {
        FeedCoordinator(store: sender.globalPackages.feedStore)
    }

    private var library: some View {
        LibraryCoordinator(store: sender.globalPackages.libraryStore)
    }

    private var create: some View {
        Text("")
    }

    private var createSheetView: some View {
        CreateCoordinator(store: sender.globalPackages.createStore, newId: $idForCreatingItem)
    }

    @ViewBuilder private func sheetContent(link: GlobalLink) -> some View {
        switch link {
        case .create: createSheetView
        case .promo: Text("Promo").bold()
        default: EmptyView()
        }
    }

    private func tabLabel(for link: GlobalLink) -> some View {
        switch link {
        case .gallery:
            return Label("Gallery", systemImage: "sparkles.rectangle.stack")
        case .create:
            return Label("", systemImage: "plus.circle")
        case .library:
            return Label("Library", systemImage: "person.crop.rectangle.fill")
        default:
            return Label("", systemImage: "")
        }
    }

}
