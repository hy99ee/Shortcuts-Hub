import Combine
import SwiftUI

struct PositionObservingView<Content: View>: View {
    @Binding var offset: CGPoint
    let coordinateSpace: CoordinateSpace

    @ViewBuilder var content: () -> Content

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
                    offset = position
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
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat
    @ViewBuilder var content: () -> Content

    @State private var lastOffset: CGPoint = .init()

    private let coordinateSpaceName = UUID()

    var body: some View {
        ScrollView(showsIndicators: false) {
            PositionObservingView(
                offset: $offset,
                coordinateSpace: .named(coordinateSpaceName)
            ) { content().scaleEffect(scale, anchor: .top) }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onChange(of: offset) { newOffset in
            if newOffset.y > 0 && (newOffset.y > lastOffset.y || scale != 1) {
                let scale = 1 - newOffset.y / 500
                self.scale = scale > 1 ? 1 : scale
            }
            lastOffset = newOffset
        }
    }
}
