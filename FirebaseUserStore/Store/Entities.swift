import Combine
import SwiftUI

protocol Mutation {}

protocol Action {}

protocol StateType {
    var processViewProgress: ProcessViewProvider { get }
}

extension StateType {
    var processViewProgress: ProcessViewProvider { .shared }
}

protocol TransitionType: Hashable, Identifiable {}

protocol TransitionSender {
    associatedtype SenderTransitionType: TransitionType

    var transition: PassthroughSubject<SenderTransitionType, Never> { get }
}

typealias DispatcherType<ActionType: Action, MutationType: Mutation, EnvironmentPackagesType: EnvironmentPackages> = ( _ action: ActionType, _ packages: EnvironmentPackagesType) -> AnyPublisher<MutationType, Never>

typealias ReducerType<StoreState: StateType, StoreMutation: Mutation, Transition: TransitionType> = (_ state: StoreState, _ mutation: StoreMutation) -> AnyPublisher<(StoreState, Transition?), Never>

protocol EnvironmentType {
    associatedtype ServiceError: Error
}



protocol EnvironmentPackages {}

//enum TransitionDestination {
//    case path(route: String)
//    case sheet(description: String)
//}

//enum StateTransitionType {
//    case path(route: String)
//    case sheet
//}

//typealias StateTransition = (destination: TransitionDestination, type: StateTransitionType)

//let stateTransition = PassthroughSubject<TransitionDestination, Never>()


//extension TransitionSender {
//    var transition: PassthroughSubject<TransitionDestination, Never> { stateTransition }
//}
//
//protocol TransitionReceiver {
//    var receiveTransition: AnySubscriber<TransitionDestination, Never> { get }
//}

