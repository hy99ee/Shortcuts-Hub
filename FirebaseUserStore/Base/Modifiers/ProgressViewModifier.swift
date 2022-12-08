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
            }
        }
        
    }
}

struct ButtonProgressViewModifier<ProgressProvider: ProgressViewProviderType>: ViewModifier {
    enum ModifierType {
        case clearView
        case buttonView
    }
    
    @ObservedObject var provider: ProgressProvider
    private let backgroundColor: Color
    private let progressViewColor: Color
    private let scale: CGFloat

    init(provider: ProgressProvider, type: ModifierType) {
        self.provider = provider

        switch type {
        case .buttonView:
            self.backgroundColor = .blue
            self.progressViewColor = .white
            self.scale = 1.2
        
        case .clearView:
            self.backgroundColor = Color(UIColor.systemBackground)
            self.progressViewColor = .blue
            self.scale = 1.1
        }
    }
    

    func body(content: Content) -> some View {
        let announcingResult = Binding<Bool>(
            get: { self.provider.progressStatus != .stop },
            set: { _ in self.provider.progressStatus = .stop }
        )
        ZStack {
            if announcingResult.wrappedValue {
                content.overlay {
                    ZStack {
                        Color(.clear).background(backgroundColor)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: progressViewColor))
                            .scaleEffect(scale)
                    }
                }.mask(content)
            } else {
                content
            }
        }
    }
}
