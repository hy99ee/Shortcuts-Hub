import SwiftUI

protocol Mutation {}

protocol Action {}

protocol StateType {}

enum ProgressViewStatus {
    case start
    case stop

    mutating func toggle() {
        if self == .stop { self = .start }
        else { self = .stop }
    }
}

class ProgressViewProvider: ProgressViewProviderType {
    @Published var progressStatus: ProgressViewStatus = .stop
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
