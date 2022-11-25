import SwiftUI

protocol SheetProviderType: ObservableObject {
    associatedtype SheetView: View
    var sheetView: SheetView? { get set }
    var presentationDetent: Set<PresentationDetent> { get set }
}

struct SheetShowViewModifier<SheetProvider: SheetProviderType>: ViewModifier {
    @ObservedObject var provider: SheetProvider

    func body(content: Content) -> some View {
        let announcingResult = Binding<Bool>(
            get: { self.provider.sheetView != nil },
            set: { _ in self.provider.sheetView = nil }
        )
        content
            .sheet(isPresented: announcingResult) {
                self.provider.sheetView
                    .presentationDetents(self.provider.presentationDetent)
            }
    }
}
