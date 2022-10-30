import Foundation

protocol Mutation {}

protocol Action {}

protocol StateType {}

typealias StateWithAlert = (StateType & WithAlertProvider)

protocol WithAlertProvider {
    associatedtype ProviderType: AlertProviderType
    var alertProvider: ProviderType { get }
}

class AlertProvider: AlertProviderType {
    @Published var error: Error?
}
