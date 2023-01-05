import Combine
import SwiftUI

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

class ProcessViewProvider: ProcessViewProviderType {
    @Published var processViewStatus: Bool = false

    init(_ provider: ProgressViewProvider) {
        provider.$progressStatus
            .map { $0 == .start }
            .assertNoFailure()
            .assign(to: &$processViewStatus)
    }
    
    init(
        _ provider1: ProgressViewProvider,
        _ provider2: ProgressViewProvider
    ) {
        Publishers.CombineLatest(
            provider1.$progressStatus,
            provider2.$progressStatus
        )
        .map { $0.0 == .start || $0.1 == .start }
        .assertNoFailure()
        .assign(to: &$processViewStatus)
    }
    
    init(
        _ provider1: ProgressViewProvider,
        _ provider2: ProgressViewProvider,
        _ provider3: ProgressViewProvider
    ) {
        Publishers.CombineLatest3(
            provider1.$progressStatus,
            provider2.$progressStatus,
            provider3.$progressStatus
        )
        .map { $0.0 == .start || $0.1 == .start || $0.2 == .start }
        .assertNoFailure()
        .assign(to: &$processViewStatus)
    }

    init(
        _ provider1: ProgressViewProvider,
        _ provider2: ProgressViewProvider,
        _ provider3: ProgressViewProvider,
        _ provider4: ProgressViewProvider
    ) {
        Publishers.CombineLatest4(
            provider1.$progressStatus,
            provider2.$progressStatus,
            provider3.$progressStatus,
            provider4.$progressStatus
        )
        .map { $0.0 == .start || $0.1 == .start || $0.2 == .start || $0.3 == .start }
        .assertNoFailure()
        .assign(to: &$processViewStatus)
    }
    
}

class SheetProvider<SheetViewType>: SheetProviderType where SheetViewType: View {
    var presentationDetent: Set<PresentationDetent>
    @Published var sheetView: SheetViewType?

    init(presentationDetent: Set<PresentationDetent> = Set()) {
        self.presentationDetent = presentationDetent
    }
}

class AboutSheetProvider: SheetProvider<AboutView> {
    override init(presentationDetent: Set<PresentationDetent> = [.height(200), .medium]) {
        super.init(presentationDetent: presentationDetent)
    }

    func initialize(with data: AboutViewData) {
        super.sheetView = AboutView(aboutData: data)
    }
}

class RegisterSheetProvider: SheetProvider<RegisterView> {
    override init(presentationDetent: Set<PresentationDetent> = Set()) {
        super.init(presentationDetent: presentationDetent)
    }

    func initialize(with store: LoginStore) {
        super.sheetView = RegisterView(store: store)
    }
}

class ForgotSheetProvider: SheetProvider<ForgotPasswordView> {
    @Published var isValidEmailField = true

    override init(presentationDetent: Set<PresentationDetent> = Set()) {
        super.init(presentationDetent: presentationDetent)
    }

    func initialize(with store: LoginStore) {
        super.sheetView = ForgotPasswordView(store: store)
    }

    func deinitialize() {
        super.sheetView = nil
        self.isValidEmailField = true
    }
}
