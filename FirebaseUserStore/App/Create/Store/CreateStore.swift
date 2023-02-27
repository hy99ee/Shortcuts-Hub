import Combine
import Foundation

typealias CreateStore = StateStore<CreateState, CreateAction, CreateMutation, LibraryPackages, CloseTransition>

//
//static let middlewareAuthCheck: CreateStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
//    
//}
