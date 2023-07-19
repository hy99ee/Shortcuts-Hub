import SwiftUI
import Combine

struct FeedCollectionView: View {
    @StateObject var store: FeedStore
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    @State private var isAnimating = false
    @State private var isUpdating = false
    @State private var clickedSectionIdScale: UUID?
//    @State private var clickedSectionIdOpacity: UUID?

    private let progress = HDotsProgress()

    var body: some View {
        verticalGrid
    }

    private var verticalGrid: some View {
        ScrollView(showsIndicators: false) {
            if store.state.sections.count > 0 {
                ForEach(store.state.sections) { section in
                    ItemsSectionView.createSectionView(section: section)
                        .frame(height: 480)
                        .matchedGeometryEffect(id: section.id, in: namespaceWrapper.namespace)
                        .cornerRadius(9)
                        .padding(.vertical)
                        .scaleEffect(section.id == clickedSectionIdScale ? 0.95 : 1)
                        .onTapGesture {
//                            withAnimation(.easeIn(duration: 0.15)) {
//                                clickedSectionIdScale = section.id
//
//                            }
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                clickedSectionIdOpacity = section.id
//                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                store.dispatch(.click(section))
                                
//                                withAnimation(.spring().speed(2)) {
//                                    clickedSectionIdScale = nil
//                                }
                            }
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                clickedSectionIdOpacity = nil
//                            }
                        }
//                        .onAppear {
//                            clickedSectionIdScale = nil
//                        }
                }
                .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
            } else {
                progress
            }
        }
//        .animationAdapted(animationDuration: 0.5)
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
