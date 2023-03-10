import Foundation
import SwiftUI
import Combine

enum LoginLink: TransitionType {
    case forgot
    case register
    case error(_ error: Error)

    case close

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
        case .close:
            hasher.combine(3)
        }
    }

    static func == (lhs: LoginLink, rhs: LoginLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct LoginCoordinator: CoordinatorType {
    @State private(set) var path = NavigationPath()
    @State private(set) var fullcover: LoginLink?
    @State private(set) var sheet: LoginLink?
    @State private(set) var alert: LoginLink?

    @Binding private var parent: LibraryLink?

    @Environment(\.presentationMode) var presentationMode

    @StateObject private var store: LoginStore
    let stateReceiver: AnyPublisher<LoginLink, Never>

    @ViewBuilder private var rootView: some View {
        LoginView().environmentObject(store)
    }

    init(store: LoginStore, parent: Binding<LibraryLink?>) {
        self._store = StateObject(wrappedValue: store)
        self.stateReceiver = store.transition.eraseToAnyPublisher()

        self._parent = parent
    }

    var view: AnyView {
        AnyView(_view)
    }
    @ViewBuilder private var _view: some View {
        NavigationStack(path: $path) {
            ZStack {
                rootView
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }, label: {
                                Text("Cancel")
                            })
                            .modifier(ProcessViewModifier(process: store.state.processView))
                        }
                    }
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
        case .close:
            self.parent = nil
        }
    }

    @ViewBuilder private func linkDestination(link: LoginLink) -> some View {
        switch link {
        case .register:
            RegisterationCoordinator(store: store.packages.registerStore, parent: $parent)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func sheetContent(link: LoginLink) -> some View {
        switch link {
        case .forgot:
            ForgotCoordinator(store: store.packages.forgotStore, parent: $sheet)
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
