import Foundation
import SwiftUI
import Combine

enum LoginLink: TransitionType {
    case forgot
    case register

    var id: String {
        String(describing: self)
    }
}

class LoginTransitionState: ObservableObject {
    @Published var path = NavigationPath()
    @Published var fullcover: LoginLink?
    @Published var sheet: LoginLink?

    private var subscriptions = Set<AnyCancellable>()

    init<T: TransitionSender>(sender: T) where T.SenderTransitionType == LoginLink {
        sender.transition.sink {[weak self] transition in
            guard let self else { return }
            switch transition {
            case .forgot: self.path.append(transition)
            case .register: self.sheet = transition
            }
        }
        .store(in: &subscriptions)
    
    }
}

struct LoginCoordinator<Content: View>: View {
    @ObservedObject var state: LoginTransitionState
    let root: Content

    var body: some View {
        NavigationStack(path: $state.path) {
            ZStack {
                root
                    .fullScreenCover(item: $state.fullcover, content: coverContent)
                    .sheet(item: $state.sheet, content: sheetContent)
            }
            .navigationDestination(for: LoginLink.self, destination: linkDestination)
        }
    }

    @ViewBuilder private func linkDestination(link: LoginLink) -> some View {
        switch link {
        case .forgot:
            ForgotPasswordView(store: ForgotStore(state: ForgotState(), dispatcher: forgotDispatcher, reducer: forgotReducer, packages: ForgotPackages()))
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func coverContent(link: LoginLink) -> some View {
        switch link {
        case .forgot:
            EmptyView()
        case .register:
            EmptyView()
        }
    }

    @ViewBuilder private func sheetContent(link: LoginLink) -> some View {
        switch link {
        case .forgot:
            EmptyView().presentationDetents([.height(200), .medium])
        case .register:
            EmptyView()
        }
    }
}
