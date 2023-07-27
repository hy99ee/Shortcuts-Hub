import Combine
import SwiftUI

struct PositionObservingView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @Binding var offset: CGFloat

    let coordinateSpace: CoordinateSpace

    var body: some View {
        content()
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: PreferenceKey.self,
                            value: geometry.frame(in: coordinateSpace).origin
                        )
                }
                .onPreferenceChange(PreferenceKey.self) { position in
                    offset = position.y
                }
            }
    }
}

private extension PositionObservingView {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
    }
}

struct OffsetObservingScrollView<Content: View>: View {
    @Binding var scale: CGFloat
    @Binding var offset: CGFloat
    @ViewBuilder var content: () -> Content

    @State private var lastOffsetY: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    private let coordinateSpaceName = UUID()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            PositionObservingView(
                content: {
                    content()
                        .scaleEffect(scale, anchor: .top)
                },
                offset: $offset,
                coordinateSpace: .named(coordinateSpaceName)
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onChange(of: offset) { newOffset in
            if newOffset > 0 && (newOffset > lastOffsetY || scale != 1) {
                let scale = 1 - newOffset / 500
                self.scale = scale > 1 ? 1 : scale
            } else {
                scrollOffset = newOffset
            }

            lastOffsetY = newOffset
        }
    }
}
