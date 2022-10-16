import Foundation

protocol StateType {}

protocol Mutation {}

protocol Action {}

protocol StateStore {
    var stateList: [StateType] { get }
}
