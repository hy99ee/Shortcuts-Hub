import Combine
import SwiftUI

typealias ForgotStore = StateStore<ForgotState, ForgotAction, ForgotMutation, ForgotPackages, GlobalLink>

//extension ForgotStore {
//    enum Transition: TransitionDestination {
//        case forgot
//        case register
//
//        @ViewBuilder var view: any View {
//            switch self {
//            case .forgot:
//                ForgotPasswordView(store: ForgotStore(state: ForgotState(), dispatcher: forgotDispatcher, reducer: forgotReducer, packages: ForgotPackages()))
//            case .register:
//                EmptyView()
//            }
//        }
//    }
//}
