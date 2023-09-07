import SwiftUI

struct ProgressViewModifier: ViewModifier {
    var progressStatus: ProgressViewStatus
    let backgroundOpacity: Double

    func body(content: Content) -> some View {
        content
            .opacity(progressStatus == .start ? backgroundOpacity : 1)
            .overlay {
                if progressStatus == .start {
                    ZStack {
                        VStack {
                            HDotsProgress()
                            Spacer()
                        }
                    }
                }
            }
    }
}

struct SimpleProgressViewModifier: ViewModifier {
    var progressStatus: ProgressViewStatus

    func body(content: Content) -> some View {
        if progressStatus == .start {
            content
                .opacity(0.5)
                .disabled(true)
        } else {
            content
        }
    }
}

struct AnimationProgressViewModifier: ViewModifier {
    @State private var isAnimating = false
    @State var active: Bool = false

    let progressStatus: ProgressViewStatus

    func body(content: Content) -> some View {
        content
            .disabled(active)
            .opacity(isAnimating ? 0.5 : 1)
            .onChange(of: progressStatus) {
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
    }
}

struct ButtonProgressViewModifier: ViewModifier {
    enum ModifierType {
        case clearView
        case backgroundView
        case buttonView
    }
    
    private let progressStatus: ProgressViewStatus
    private let type: ModifierType
    private let backgroundColor: Color
    private let progressViewColor: Color
    private let scale: CGFloat

    init(progressStatus: ProgressViewStatus, type: ModifierType) {
        self.progressStatus = progressStatus
        self.type = type

        switch type {
        case .buttonView:
            self.backgroundColor = .blue
            self.progressViewColor = .white
            self.scale = 1.2

        case .backgroundView:
            self.backgroundColor = Color(UIColor.systemBackground)
            self.progressViewColor = Color(UIColor.label)
            self.scale = 1.5
        
        case .clearView:
            self.backgroundColor = Color(UIColor.red)
            self.progressViewColor = .blue
            self.scale = 1.1
        }
    }
    

    func body(content: Content) -> some View {
        if progressStatus != .stop {
            switch type {
            case .backgroundView:
                content.overlay {
                    ZStack {
                        Color(.clear).background(backgroundColor)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: progressViewColor))
                            .scaleEffect(scale)
                    }
                }
            default:
                content.overlay {
                    ZStack {
                        Color(.clear).background(backgroundColor)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: progressViewColor))
                            .scaleEffect(scale)
                    }
                }.mask(content)
            }
        } else {
            content
        }
    }
}

struct ButtonClearProgressViewModifier: ViewModifier {
    private let progressStatus: ProgressViewStatus
    private let backgroundColor: Color
    private let progressViewColor: Color
    private let scale: CGFloat

    init(progressStatus: ProgressViewStatus) {
        self.progressStatus = progressStatus

        self.backgroundColor = Color(UIColor.systemBackground)
        self.progressViewColor = .blue
        self.scale = 1.1
    }
    

    func body(content: Content) -> some View {
        if progressStatus != .stop {
            ZStack {
                Color(.clear).background(backgroundColor).opacity(0.001)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: progressViewColor))
                    .scaleEffect(scale)
            }

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
