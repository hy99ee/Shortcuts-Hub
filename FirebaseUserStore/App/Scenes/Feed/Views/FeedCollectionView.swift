import SwiftUI
import Combine

fileprivate var savedOffset: CGPoint = .init(x: 0, y: -100)

struct FeedCollectionView: View {
    @StateObject var store: FeedStore
    @Binding var clickedSection: IdsSection?
    @Binding var previousClickedSection: IdsSection?
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    @State private var __offset = savedOffset
    @State private var offset = savedOffset
    @State private var isUpdating = false

    @State private var clickedSectionIdScale: UUID?
    @State private var clickedSectionIdOpacity: UUID?
    private let coordinateSpaceName = UUID()

    private let progress = HDotsProgress()

    var body: some View {
        verticalGrid
//        collectionView
    }

//    private var collectionView: some View {
//        ScrollView(showsIndicators: false) {
//            ScrollViewReader { proxy in
//                ZStack {
//                    LazyVStack {
//                        ForEach(0..<15) {
//                            Color.clear
//                                .border(.blue)
//                                .frame(height: 100)
//                                .id($0)
//                        }
//                    }
//                    content
//                    PositionObservingView(
//                        offset: $offset,
//                        coordinateSpace: .named(coordinateSpaceName)
//                    ) { Color.clear }
//                }
//                .onAppear {
//                    proxy.scrollTo(abs(Int(__offset.y * 1.8 / 100)))
//                }
//            }
//        }
//        .coordinateSpace(name: coordinateSpaceName)
//        .onAppear {
//                __offset = savedOffset
//        }
//        .onChange(of: offset) { newOffset in
//            print("---- \(newOffset)")
//            savedOffset = offset
//        }
//    }

    @ViewBuilder private var content: some View {
        if store.state.sections.count > 0 {
            LazyVStack {
                ForEach(store.state.sections) { section in
                    ItemsSectionView(section: section)
                    
                        .equatable()
//                        .offset(y: section.id == clickedSectionIdScale ? 13 : 0)
                        .scaleEffect(section.id == clickedSectionIdScale ? 0.95 : 1)
                        .opacity(section.id == clickedSectionIdOpacity ? 0 : 1)
                        .environmentObject(namespaceWrapper)
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.18)) {
                                clickedSectionIdScale = section.id
                                previousClickedSection = section
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                withAnimation(.easeIn(duration: 0.10)) {
                                    clickedSectionIdScale = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        clickedSectionIdOpacity = section.id
                                    }
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                store.dispatch(.click(section))
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                clickedSectionIdOpacity = nil
                                clickedSectionIdScale = nil
                            }

                        }
                        .cornerRadius(9)
                        .padding(.vertical)
                        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
//                        .zIndex(section.id == previousClickedSection?.id ? 100 : 0)
                        .matchedGeometryEffect(id: "section_\(section.id)", in: namespaceWrapper.namespace)
                        .id(section.id)
                        .offset(y: section.id == clickedSectionIdScale ? 20 : 0)
                }
            }
        } else {
            progress
        }
    }

    private var verticalGrid: some View {
        ScrollViewReader { value in
            ScrollView(showsIndicators: false) {
                content
            }
            .onAppear {
                if let id = previousClickedSection?.id {
                    withAnimation {
                        value.scrollTo(id)
                    }
                }
            }
//            .offset(y: offset)
//            .animationAdapted(animationDuration: 0.5)
            .navigationBarItems(trailing: toolbarView)
            .refreshable {
                await asyncUpdate()
            }
        }
    }
    
    private var toolbarView: some View {
        HStack {
        }
    }

    private func asyncUpdate() async -> Void {
        store.dispatch(.updateFeed)

        try? await self.store.objectWillChange
            .filter { self.store.state.viewProgress == .stop }
            .handleEvents(receiveOutput: { _ in isUpdating = false })
            .eraseToAnyPublisher()
            .async()
    }
}
