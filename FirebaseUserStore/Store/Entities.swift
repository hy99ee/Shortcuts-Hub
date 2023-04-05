import Combine
import SwiftUI

protocol Action: Equatable {}

protocol Mutation {}

enum EquivocalMutation<State, Transition> where State: StateType, Transition: TransitionType {
    case state(_ state: State)
    case coordinate(destination: Transition)
}

protocol Reinitable {
    func reinit() -> Self
}

protocol ReinitableBySelf: Reinitable {}
extension ReinitableBySelf {
    func reinit() -> Self { self }
}
protocol ReinitableByNewSelf: Reinitable {
    init()
}
extension ReinitableByNewSelf {
    func reinit() -> Self { Self() }
}

protocol StateType: ReinitableByNewSelf, Equatable {}

protocol TransitionType: Hashable, Identifiable {}
enum NoneTransition : TransitionType {
    case none

    var id: String { String(describing: self) }
}
enum CloseTransition : TransitionType {
    case close

    var id: String { String(describing: self) }
}

protocol TransitionSender {
    associatedtype SenderTransitionType: TransitionType

    var transition: PassthroughSubject<SenderTransitionType, Never> { get }
}

typealias DispatcherType<ActionType: Action, MutationType: Mutation, EnvironmentPackagesType: EnvironmentPackages> = ( _ action: ActionType, _ packages: EnvironmentPackagesType) -> AnyPublisher<MutationType, Never>

typealias ReducerType<StoreState: StateType, StoreMutation: Mutation, Transition: TransitionType> = (_ state: StoreState, _ mutation: StoreMutation) -> AnyPublisher<EquivocalMutation<StoreState, Transition>, Never>

protocol EnvironmentType {
    associatedtype ServiceError: Error
}

protocol EnvironmentPackages: Reinitable {
    var sessionService: SessionService { get }
}
extension EnvironmentPackages {
    var sessionService: SessionService { SessionService.shared }
}

protocol Unreinitable {}
extension Unreinitable {
    func reinit() -> Self { self }
}

extension NavigationPath {
    static let coordinatorsShared = NavigationPath()
}
protocol CoordinatorType: View {
    associatedtype Link: TransitionType

    var stateReceiver: AnyPublisher<Link, Never> { get }

    var path: NavigationPath { get }
    var alert: Link? { get }
    var sheet: Link? { get }
    var fullcover: Link? { get }

    var view: AnyView { get }
    
    func transitionReceiver(_ link: Link)
}

extension CoordinatorType {
    var path: NavigationPath { NavigationPath.coordinatorsShared }
    var alert: Link? { nil }
    var sheet: Link? { nil }
    var fullcover: Link? { nil }

    var body: some View {
        view
        .onReceive(stateReceiver) {
            transitionReceiver($0)
        }
    }
}
