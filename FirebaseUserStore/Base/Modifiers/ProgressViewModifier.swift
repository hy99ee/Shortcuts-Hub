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
        content
            .opacity(announcingResult.wrappedValue ? 0.5 : 1)
            .overlay {
                if announcingResult.wrappedValue {
                    ZStack {
                        HDotsProgress()
                    }
                }
            }
    }
}

struct SimpleProgressViewModifier<ProgressProvider: ProgressViewProviderType>: ViewModifier {
    @ObservedObject var provider: ProgressProvider

    func body(content: Content) -> some View {
        let announcingResult = Binding<Bool>(
            get: { self.provider.progressStatus != .stop },
            set: { _ in self.provider.progressStatus = .stop }
        )
        if announcingResult.wrappedValue {
            content
                .opacity(0.5)
                .disabled(true)
        } else {
            content
        }
    }
}

struct AnimationProgressViewModifier<ProgressProvider: ProgressViewProviderType>: ViewModifier {
    @State private var isAnimating = false
//    @State var animation: Animation = .easeIn(duration: 0.5).repeatForever
    @State var active: Bool = false

    @ObservedObject var provider: ProgressProvider
//    let animation: Animation

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.5 : 1)
            .onChange(of: provider.progressStatus) {
                if $0 == .start {
                    active = true
                } else {
                    active = false
                }
            }
            .onChange(of: active) {
                withAnimation($0
                              ? .easeIn(duration: 0.5).repeatForever()
                              : .easeIn(duration: 0.5)
                ) {
                    isAnimating.toggle()
                }
            }
//            .onChange(of: animation) { newAnimation in
//                withAnimation(newAnimation) {
//                    isAnimating.toggle()
//                }
//            }
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

struct StaticPreloaderViewModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.5 : 1)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5).repeatForever()) {
                    isAnimating = true
                }
            }
    }
}
