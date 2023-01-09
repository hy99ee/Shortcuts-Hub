import SwiftUI

class AboutSheetProvider: SheetProvider<AboutView> {
    override init(presentationDetent: Set<PresentationDetent> = [.height(200), .medium]) {
        super.init(presentationDetent: presentationDetent)
    }

    func initialize(with data: AboutViewData) {
        super.sheetView = AboutView(aboutData: data)
    }
}
