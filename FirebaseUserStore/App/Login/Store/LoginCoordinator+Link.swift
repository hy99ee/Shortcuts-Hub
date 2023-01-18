import Foundation
import SwiftUI
import Combine

enum LoginLink: TransitionType {
    case forgot
    case register

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .forgot:
            hasher.combine(0)
        case .register:
            hasher.combine(1)
        }
    }

    static func == (lhs: LoginLink, rhs: LoginLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct LoginCoordinator: CoordinatorType {
    @State var path = NavigationPath()
    @State var fullcover: LoginLink?
    @State var sheet: LoginLink?

    private var store: LoginStore
    let stateReceiver: AnyPublisher<LoginLink, Never>
    @ViewBuilder private var rootView: some View {
        LoginView().environmentObject(store)
    }

    init(store: LoginStore) {
        self.store = store
        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }

    var view: AnyView {
        AnyView(_view)
    }
    @ViewBuilder private var _view: some View {
        NavigationStack(path: $path) {
            ZStack {
                rootView
                    .fullScreenCover(item: $fullcover, content: coverContent)
            }
            .navigationDestination(for: LoginLink.self, destination: linkDestination)
        }
    }

    func transitionReceiver(_ link: LoginLink) {
        switch link {
        case .forgot:
            self.fullcover = link
        case .register:
            self.path.append(link)
        }
    }

    @ViewBuilder private func linkDestination(link: LoginLink) -> some View {
        switch link {
        case .register:
            RegisterView(store: RegisterationStore(state: RegisterationState(), dispatcher: registerationDispatcher, reducer: registerationReducer, packages: RegisterationPackages()))
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func coverContent(link: LoginLink) -> some View {
        switch link {
        case .forgot:
            ForgotPasswordView(store: ForgotStore(state: ForgotState(), dispatcher: forgotDispatcher, reducer: forgotReducer, packages: ForgotPackages())).applyClose(.view)
        default:
            EmptyView()
        }
    }
}
