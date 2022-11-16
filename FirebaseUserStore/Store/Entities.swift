import SwiftUI

protocol Mutation {}

protocol Action {}

protocol StateType {}

typealias StateWithAlert = (StateType & WithAlertProvider)

protocol WithAlertProvider {
    associatedtype ProviderType: AlertProviderType
    var alertProvider: ProviderType { get }
}

protocol WithSheetProvider {
    associatedtype ProviderType: SheetProviderType
    var sheetProvider: ProviderType { get }
}

class AlertProvider: AlertProviderType {
    @Published var error: Error?
}

class SheetProvider<SheetViewType>: SheetProviderType where SheetViewType: View {
    var presentationDetent: Set<PresentationDetent>
    @Published var sheetView: SheetViewType?

    init(presentationDetent: Set<PresentationDetent>) {
        self.presentationDetent = presentationDetent
    }
}
