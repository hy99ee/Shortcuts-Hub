import SwiftUI

class ForgotSheetProvider: SheetProvider<ForgotPasswordView> {
    override init(presentationDetent: Set<PresentationDetent> = Set()) {
        super.init(presentationDetent: presentationDetent)
    }

    func initialize() {
        super.sheetView = ForgotPasswordView(store: ForgotStore(
            state: ForgotState(),
            dispatcher: forgotDispatcher,
            reducer: forgotReducer,
            packages: ForgotPackages()
        ))
    }

    func deinitialize() {
        super.sheetView = nil
    }
}
