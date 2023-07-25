import SwiftUI
import Combine

struct FeedCollectionView: View {
    @StateObject var store: FeedStore
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    @State private var offset: CGFloat = 0
    @State private var isUpdating = false
    @State private var clickedSectionIdScale: UUID?
    @State private var previousClickedSectionId: UUID?
    @State private var clickedSectionIdOpacity: UUID?

    @State private var zIndexMax: Double = 100

    private let progress = HDotsProgress()

    var body: some View {
        verticalGrid
    }

    private var verticalGrid: some View {
        ScrollView(showsIndicators: false) {
            if store.state.sections.count > 0 {
                ForEach(store.state.sections) { section in
                    ItemsSectionView(section: section)
                        .equatable()
                        .environmentObject(namespaceWrapper)
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    withAnimation(.spring().speed(1.5)) {
                                        clickedSectionIdScale = section.id
                                        previousClickedSectionId = section.id

                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            clickedSectionIdOpacity = section.id
                                        }

                                        store.dispatch(.click(section))
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        clickedSectionIdOpacity = nil
                                        clickedSectionIdScale = nil
                                    }
                                }

                        )
                        .cornerRadius(9)
                        .padding(.vertical)
                        .offset(y: section.id == clickedSectionIdScale ? 15 : 0)
                        .scaleEffect(section.id == clickedSectionIdScale ? 0.95 : 1)
                        .opacity(section.id == clickedSectionIdOpacity ? 0 : 1)
                        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
                        .zIndex(section.id == previousClickedSectionId ? 100 : 0)
                        .matchedGeometryEffect(id: "section_\(section.id)", in: namespaceWrapper.namespace, properties: .position, isSource: previousClickedSectionId == section.id)
                }
            } else {
                progress
            }
        }
        .offset(y: offset)
        .animationAdapted(animationDuration: 0.5)
        .navigationBarItems(trailing: toolbarView)
        .refreshable {
            await asyncUpdate()
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
