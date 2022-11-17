import SwiftUI

protocol ProgressViewProviderType: ObservableObject {
    var progressStatus: ProgressViewStatus { get set }
}

struct ProgressViewModifier<ProgressProvider: ProgressViewProviderType>: ViewModifier {
    @ObservedObject var provider: ProgressProvider

    func body(content: Content) -> some View {
        let announcingResult = Binding<Bool>(
            get: { self.provider.progressStatus != .stop },
            set: { _ in self.provider.progressStatus = .stop }
        )
        ZStack {
            content
            if announcingResult.wrappedValue {
                Color(.systemBackground)
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .scaleEffect(2)
            }
        }
        
    }
}
