import Foundation

protocol StateType {}

protocol Mutation {}

protocol Action {}

typealias StateWithAlert = (StateType & WithAlertProvider)

protocol WithAlertProvider {
    associatedtype ProviderType: AlertProviderType
    var alertProvider: ProviderType { get }
}

class AlertProvider: AlertProviderType {
    @Published var error: Error?
}
