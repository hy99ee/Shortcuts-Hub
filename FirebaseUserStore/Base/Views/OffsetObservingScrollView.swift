import Combine
import SwiftUI

struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace

    @StateObject private var scrollViewManager = ScrollViewManager()

    @Binding var offset: CGPoint
    @Binding var scale: CGFloat

    @ViewBuilder var content: () -> Content
    
    var body: some View {
        content()
            .scaleEffect(scale)
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: PreferenceKey.self,
                        value: geometry.frame(in: coordinateSpace).origin
                    )
                }
            )
            .onPreferenceChange(PreferenceKey.self) { position in
                scrollViewManager.currentOffset = position
            }
            .onReceive(scrollViewManager.$offsetAtScrollEnd) { _ in
                withAnimation(.spring()) {
                    offset = .zero
                    scale = 1
                }
            }
            .onReceive(scrollViewManager.$currentOffset) {
                self.offset = $0
            }
    }
}

private extension PositionObservingView {
    class ScrollViewManager: ObservableObject {
        @Published var currentOffset: CGPoint = .zero
        @Published var offsetAtScrollEnd: CGFloat = 0

        private var cancellable: AnyCancellable?

        init() {
            cancellable = AnyCancellable($currentOffset
                .map { $0.y }
                .debounce(for: 0.18, scheduler: DispatchQueue.main)
                .dropFirst()
                .assign(to: \.offsetAtScrollEnd, on: self)
            )
        }
    }

    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
    }
}

struct OffsetObservingScrollView<Content: View>: View {
    var axes: Axis.Set = [.vertical]
    var showsIndicators = false
    @Binding var scale: CGFloat
    @ViewBuilder var content: () -> Content

    @State var offset: CGPoint = .zero
    @State private var lastOffsetY: CGFloat = .zero

    private let coordinateSpaceName = UUID()

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                offset: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(
                            x: -newOffset.x,
                            y: -newOffset.y
                        )
                    }
                ),
                scale: $scale,
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onChange(of: offset) { newOffset in
            if newOffset.y <= 0 {
                let scale = newOffset.y < lastOffsetY ? scale + newOffset.y / 20_000 : scale - newOffset.y / 20_000
                self.scale = scale > 1 ? 1 : scale
                lastOffsetY = newOffset.y
            } else {
                if scale < 1 {
                    let scale = scale + newOffset.y / 20_000
                    self.scale = scale > 1 ? 1 : scale
                }
            }
        }
    }
}





