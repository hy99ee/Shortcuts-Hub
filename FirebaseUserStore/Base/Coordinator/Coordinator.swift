import SwiftUI
import Combine

enum GlobalLink: TransitionType {
    case login
    case logout

    case promo

    var id: String {
        String(describing: self)
    }
}

class GlobalTransition: ObservableObject {
    @Published var path = NavigationPath()
    @Published var promoSheet: GlobalLink?

    private var subscriptions = Set<AnyCancellable>()

    init<T: TransitionSender>(sender: T) where T.SenderTransitionType == GlobalLink {
        sender.transition.sink {[weak self] transition in
            guard let self else { return }
            switch transition {
            case .login:
                self.path.append("login")
            case .logout:
                self.path.append("logout")
            case .promo:
                self.promoSheet = transition
            }
        }
        .store(in: &subscriptions)
    
    }
}

struct GlobalCoordinator<Content: View>: View {
    @ObservedObject var state: GlobalTransition
    let content: () -> Content

    private let storeRepository = GlobalStoreRepository.shared

    var body: some View {
        NavigationStack(path: $state.path) {
            ZStack {
                content()
                    .fullScreenCover(item: $state.promoSheet, content: coverContent)
            }
            .navigationDestination(for: GlobalLink.self, destination: linkDestination)
        }
    }

    @ViewBuilder private func linkDestination(link: GlobalLink) -> some View {
        switch link {
        case .login:
            FeedView(store: storeRepository.feedStore)
        case .logout:
            LoginView()
                .environmentObject(storeRepository.loginStore)
        default:
            ProgressView().background(.green)
        }
    }

    @ViewBuilder private func coverContent(link: GlobalLink) -> some View {
        switch link {
        case .promo:
            ProgressView().background(.red)
        default:
            EmptyView()
        }
    }
}
