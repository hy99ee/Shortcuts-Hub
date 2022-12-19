import SwiftUI
//
//enum AnimationState: Int {
//    case idle = 0,
//         pulling,
//         ongoing
//}
//
//struct PullToRefresh: Equatable {
//    var progress: Double
//    var state: AnimationState
//    var offset: CGFloat
//}
//
//enum Constants {
//    static let maxOffset = 100.0
//    static let ballSize = 42.0
//    static let ballSpacing = 8.0
//    static let jumpDuration = 0.35
//}
//
//struct ScrollViewGeometryReader: View {
//    // 1
//    @Binding var pullToRefresh: PullToRefresh
//
//    // 2
//    let update: () async -> Void
//
//    // 3
//    @State private var startOffset: CGFloat = 0
//
//    var body: some View {
//        GeometryReader<Color> { proxy in // 1
//            Task { calculateOffset(from: proxy) }
//          return Color.clear // 2
//        }
//        .task { // 3
//          await update()
//        }
//    }
//
//    private func calculateOffset(from proxy: GeometryProxy) {
//        let currentOffset = proxy.frame(in: .global).minY
//
//        switch pullToRefresh.state {
//        case .idle:
//            startOffset = currentOffset // 1
//            pullToRefresh.state = .pulling // 2
//
//        case .pulling where pullToRefresh.progress < 1: // 3
//            pullToRefresh.progress = min(1, (currentOffset - startOffset) / Constants.maxOffset)
//            pullToRefresh.offset = currentOffset
//
//        case .pulling: // 4
//            pullToRefresh.state = .ongoing
//            pullToRefresh.progress = 0
//
//            Task {
//                await update() // 5
//                pullToRefresh.state = .idle
//            }
//
//        default: return
//        }
//    }
//}
//
//struct ScrollContentView: View {
//    let update: () async -> Void = { try! await Task.sleep(nanoseconds: 3_000_000_000) }
//    @State var pullToRefresh = PullToRefresh(progress: 0, state: .idle, offset: 0)
//
//    var body: some View {
//        ScrollView {
//          ScrollViewGeometryReader(pullToRefresh: $pullToRefresh) {
//            await update()
//            print("Updated!")
//          }
//          ZStack(alignment: .top) {
//            if pullToRefresh.state == .ongoing { // 2
//                BallView(pullToRefresh: $pullToRefresh)
//            }
//            LazyVStack { // 3
//              ForEach(mockItems) {
//                  FeedCellView(title: $0.title)
//              }
//            }
//            .offset(y: pullToRefresh.offset) // 4
//          }
//        }
//    }
//}
//
//struct BallView: View {
//    @Binding var pullToRefresh: PullToRefresh
//
//    var body: some View {
//        switch pullToRefresh.state {
//        case .ongoing:
//          JumpingBallView() // 1
//        default:
//          EmptyView() // 2
//        }
//    }
//}
//
//struct Ball: View {
//  var body: some View {
//    Image(systemName: "book.circle.fill")
//      .resizable()
//      .frame(
//        width: Constants.ballSize,
//        height: Constants.ballSize
//      )
//  }
//}
//
//struct JumpingBallView: View {
//    @State private var isAnimating = false
//    @State private var rotation = 0.0
//    @State private var scale = 1.0
//    private let shadowHeight = Constants.ballSize / 2
//
//
//    var currentYOffset: CGFloat {
//      isAnimating
//        ? Constants.maxOffset - Constants.ballSize / 2 - Constants.ballSpacing
//        : -Constants.ballSize / 2 - Constants.ballSpacing
//    }
//
//    var body: some View {
//        ZStack {
//            Ellipse()
//                .fill(Color.gray.opacity(0.4))
//                .frame(
//                    width: Constants.ballSize,
//                    height: shadowHeight
//                )
//                .scaleEffect(isAnimating ? 1.2 : 0.3, anchor: .center) // 1
//                .offset(y: Constants.maxOffset - shadowHeight / 2 - Constants.ballSpacing) // 2
//                .opacity(isAnimating ? 1 : 0.3) // 3
//
//            Ball()
//                .rotationEffect(
//                    Angle(degrees: rotation),
//                    anchor: .center
//                )
//                .scaleEffect(
//                    x: 1.0 / scale,
//                    y: scale,
//                    anchor: .bottom
//                )
//                .offset(y: currentYOffset)
//                .onAppear { animate() }
//        }
//    }
//    private func animate() {
//        withAnimation(
//            .easeInOut(duration: Constants.jumpDuration)
//            .repeatForever()
//        ) { // 1
//            isAnimating = true
//        }
//
//        withAnimation(
//            .linear(duration: Constants.jumpDuration * 2)
//            .repeatForever(autoreverses: false)
//        ) { // 2
//            rotation = 360
//        }
//
//        withAnimation(
//            .easeOut(duration: Constants.jumpDuration)
//            .repeatForever()
//        ) { // 3
//            scale = 0.85
//        }
//    }
//}

struct StaggeringView<Content: View, T: Identifiable>: View where T: Hashable{
    var content: (T) -> Content
    var list: [T]
    
    var columns: Int
    var showIndicators: Bool
    var spacing: CGFloat
    
    init(
        list: [T],
        @ViewBuilder content: @escaping (T) -> Content,
        columns: Int = 1,
        spacing: CGFloat = 10,
        showIndicators: Bool = false
    ) {
        self.list = list
        self.content = content
        self.columns = columns
        self.spacing = spacing
        self.showIndicators = showIndicators
    }
    
    func setupList() -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
    
        var currentIndex: Int = 0
        
        for object in list {
            gridArray[currentIndex].append(object)
            
            if currentIndex == (columns - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }
        
        return gridArray
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: showIndicators) {
            HStack(alignment: .top) {
                ForEach(setupList(), id: \.self) { columnsData in
                    LazyVStack(spacing: spacing) {
                        ForEach(columnsData) {
                            content($0)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
