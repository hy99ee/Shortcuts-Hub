import SwiftUI

protocol AlertProviderType: ObservableObject {
    var error: Error? { get set }
}

struct AlertShowViewModifier<AlertProvider: AlertProviderType>: ViewModifier {
    @ObservedObject var provider: AlertProvider

    func body(content: Content) -> some View {
        let announcingResult = Binding<Bool>(
            get: { self.provider.error != nil },
            set: { _ in self.provider.error = nil }
        )
        content
            .alert(isPresented: announcingResult) {
                Alert(title: Text("Something went wrong"),
                      message: Text(provider.error?.localizedDescription ?? ""),
                      dismissButton: .default(Text("OK")))
            }
            
    }
}
