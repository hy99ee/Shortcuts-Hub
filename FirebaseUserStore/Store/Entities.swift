import SwiftUI

protocol Mutation {}

protocol Action {}

protocol StateType {}

protocol EnvironmentType {
    associatedtype ServiceError: Error
}

protocol EnvironmentPackages {}

enum ProgressViewStatus {
    case start
    case stop

    mutating func toggle() {
        if self == .stop { self = .start }
        else { self = .stop }
    }
}

enum ServiceResponceStatus {
    case success
    case failure
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

    init(presentationDetent: Set<PresentationDetent> = Set()) {
        self.presentationDetent = presentationDetent
    }
}
