import Foundation

protocol DispatcherType {
    associatedtype ActionType: Action
    associatedtype MutationType: Mutation
    var commit: (MutationType) -> Void { get set }
    
    init(commit: @escaping (MutationType) -> Void)
    
    func dispatch(action: ActionType)
}
