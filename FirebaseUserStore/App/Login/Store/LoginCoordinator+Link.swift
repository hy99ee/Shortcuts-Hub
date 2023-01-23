import Foundation
import SwiftUI
import Combine

enum LoginLink: TransitionType {
    case forgot
    case register
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .forgot:
            hasher.combine(0)
        case .register:
            hasher.combine(1)
        case .error:
            hasher.combine(2)
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
    @State var alert: LoginLink?

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
                    .sheet(item: $sheet, content: sheetContent)
                    .alert(item: $alert, content: alertContent)
                
            }
            .navigationDestination(for: LoginLink.self, destination: linkDestination)
        }
    }

    func transitionReceiver(_ link: LoginLink) {
        switch link {
        case .forgot:
            self.sheet = link
        case .register:
            self.path.append(link)
        case .error:
            self.alert = link
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

    @ViewBuilder private func sheetContent(link: LoginLink) -> some View {
        switch link {
        case .forgot:
            ForgotPasswordView(store: ForgotStore(state: ForgotState(), dispatcher: forgotDispatcher, reducer: forgotReducer, packages: ForgotPackages()))
                .presentationDetents([.height(200)])
        default:
            EmptyView()
        }
    }

    private func alertContent(link: LoginLink) -> Alert {
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
