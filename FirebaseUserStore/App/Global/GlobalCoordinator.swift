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

class GlobalTransition: ObservableObject {
    @Published var core: GlobalLink = .progress
    @Published var promoSheet: GlobalLink?

    private var subscriptions = Set<AnyCancellable>()

    init<T: TransitionSender>(sender: T) where T.SenderTransitionType == GlobalLink {
        sender.transition.sink {[weak self] transition in
            guard let self else { return }
            switch transition {
            case .login, .logout, .progress:
                self.core = transition
            case .promo:
                self.promoSheet = transition
            }
        }
        .store(in: &subscriptions)
    
    }
}

struct GlobalCoordinator: View {
    @ObservedObject var state: GlobalTransition

    private let storeRepository = GlobalStoreRepository.shared

    var body: some View {
        linkDestination(link: state.core)
            .fullScreenCover(item: $state.promoSheet, content: coverContent)
    }

    @ViewBuilder private func linkDestination(link: GlobalLink) -> some View {
        switch link {
        case .progress:
            HDotsProgress().scaleEffect(2)
        case .login:
            FeedCoordinator(state: storeRepository.feedState, root: feedView)
        case .logout:
            LoginCoordinator(state: storeRepository.loginState, root: loginView)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func coverContent(link: GlobalLink) -> some View {
        switch link {
        case .promo:
            ProgressView().background(.red).applyClose(onClose: $state.promoSheet, .view)
        default:
            EmptyView()
        }
    }

    private var loginView: some View { LoginView().environmentObject(storeRepository.loginStore) }
    private var feedView: some View { FeedView(store: storeRepository.feedStore) }
}
