import SwiftUI

class RegisterSheetProvider: SheetProvider<RegisterView> {
    override init(presentationDetent: Set<PresentationDetent> = Set()) {
        super.init(presentationDetent: presentationDetent)
    }

    func initialize(with store: LoginStore) {
        super.sheetView = RegisterView(store: store)
    }
}
