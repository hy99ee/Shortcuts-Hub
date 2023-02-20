import SwiftUI
import Combine

enum GlobalLink: TransitionType {
    case gallery
    case create
    case library

    case progress

    case promo

    var id: String {
        String(describing: self)
    }
}


struct GlobalCoordinator: CoordinatorType {
    @State var sheet: GlobalLink?
    @State var root: GlobalLink = .progress
    @State private var lastSelected: GlobalLink = .gallery

    let stateReceiver: AnyPublisher<GlobalLink, Never>
    private let sender: GlobalSender

    init() {
        sender = GlobalSender()
        stateReceiver = self.sender.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(_view)
    }
    @ViewBuilder private var _view: some View {
        rootView
    }

    func transitionReceiver(_ link: GlobalLink) {
        switch link {
        case .gallery, .library, .progress:
            root = link
        case .promo, .create:
            sheet = link
        }
    }

    @ViewBuilder private var rootView: some View {
        switch root {
        case .progress:
            HDotsProgress().scaleEffect(2)
        default:
            tabView
                .sheet(item: $sheet, content: sheetContent)
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
            } else {
                lastSelected = $0
            }
        }
        
    }

    @ViewBuilder private var gallery: some View {
        FeedCoordinator(store: sender.globalPackages.feedStore)
    }

    private var create: some View {
        Text("").tabItem { tabLabel(for: .create) }
    }
    private var createSheetView: some View {
        ImageView(systemName: "plus", size: 20) {
            sender.globalPackages.libraryStore.dispatch(.addItem)
        }
        .modifier(ProcessViewModifier(provider: sender.globalPackages.libraryStore.state.processView))
        .modifier(ButtonProgressViewModifier(provider: sender.globalPackages.libraryStore.state.buttonProgress, type: .clearView))
    }

    @ViewBuilder private var library: some View {
        LibraryCoordinator(store: sender.globalPackages.libraryStore)
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
