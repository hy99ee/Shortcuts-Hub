import Combine
import SwiftUI

// MARK: Store
protocol Action: Equatable {}

protocol Mutation {}

protocol Reinitable {
    func reinit() -> Self
}

protocol ReinitableByNewSelf: Reinitable {
    init()
}
extension ReinitableByNewSelf {
    func reinit() -> Self { Self() }
}

protocol Unreinitable {}
extension Unreinitable {
    func reinit() -> Self { self }
}

protocol StateType: Reinitable, Equatable {}

typealias DispatcherType<ActionType: Action, MutationType: Mutation, EnvironmentPackagesType: EnvironmentPackages> = ( _ action: ActionType, _ packages: EnvironmentPackagesType) -> AnyPublisher<MutationType, Never>

typealias ReducerType<StoreState: StateType, StoreMutation: Mutation, Transition: TransitionType> = (_ state: StoreState, _ mutation: StoreMutation) -> AnyPublisher<AmbiguousMutation<StoreState, Transition>, Never>

protocol EnvironmentType {
    associatedtype ServiceError: Error
}

protocol EnvironmentPackages: Reinitable {
    var sessionService: SessionService { get }
}
extension EnvironmentPackages {
    var sessionService: SessionService { SessionService.shared }
}


// MARK: Coordinator
protocol TransitionType: Hashable, Identifiable {}

enum AmbiguousMutation<State, Transition> where State: StateType, Transition: TransitionType {
    case state(_ state: State)
    case coordinate(destination: Transition)
}

protocol TransitionSender {
    associatedtype SenderTransitionType: TransitionType

    var transition: PassthroughSubject<SenderTransitionType, Never> { get }
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

extension NavigationPath {
    static let sharedPath = NavigationPath()
}
extension CoordinatorType {
    var path: NavigationPath { NavigationPath.sharedPath }
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

enum NoneTransition : TransitionType {
    case none

    var id: String { String(describing: self) }
}
enum CloseTransition : TransitionType {
    case close

    var id: String { String(describing: self) }
}
enum ErrorTransition : TransitionType {
    case error(error: Error)

    var id: String {
        if case let ErrorTransition.error(error) = self {
            return error.localizedDescription
        } else {
            return UUID().uuidString
        }
    }
    static func == (lhs: ErrorTransition, rhs: ErrorTransition) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }
}
