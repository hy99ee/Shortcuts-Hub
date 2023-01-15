import SwiftUI
import Combine

enum GlobalLink: TransitionType {
    case login
    case logout

    case progress

    case promo

    var id: String {
        String(describing: self)
    }
}


struct GlobalCoordinator: CoordinatorType {
    @State var sheet: GlobalLink?
    @State var root: GlobalLink = .progress

    var stateReceiver: AnyPublisher<GlobalLink, Never>
    private let sender: GlobalSender
    
    init() {
        self.sender = GlobalSender()
        stateReceiver = self.sender.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(_view)
    }
    @ViewBuilder private var _view: some View {
        rootView
            .fullScreenCover(item: $sheet, content: coverContent)
    }

    private let storeRepository = GlobalStoreRepository.shared

    func transitionReceiver(_ link: GlobalLink) {
        switch link {
        case .login, .logout, .progress:
            root = link
        case .promo:
            sheet = link
        }
    }

    @ViewBuilder private var rootView: some View {
        switch root {
        case .progress:
            HDotsProgress().scaleEffect(2)
        case .login:
            FeedCoordinator(store: storeRepository.feedStore)
        case .logout:
            LoginCoordinator(store: storeRepository.loginStore)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func coverContent(link: GlobalLink) -> some View {
        switch link {
        case .promo:
            ProgressView().background(.red).applyClose(onClose: $sheet, .view)
        default:
            EmptyView()
        }
    }
}
