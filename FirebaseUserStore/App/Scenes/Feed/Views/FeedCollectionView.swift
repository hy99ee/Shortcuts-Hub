import SwiftUI
import Combine

struct FeedCollectionView: View {
    @StateObject var store: FeedStore
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper
    
    @State private var isAnimating = false
    @State private var isUpdating = false

    private let progress = HDotsProgress()

    var body: some View {
        verticalGrid
    }

    private var verticalGrid: some View {
//        NavigationView {
            ScrollView(showsIndicators: false) {
                if store.state.sections.count > 0 {
                    ForEach(store.state.sections) { section in
                        ItemsSectionView(section: section)
                            .matchedGeometryEffect(id: section.id, in: namespaceWrapper.namespace)
                            .animation(.spring().speed(0.8), value: store.state.sections)
                            .onTapGesture { store.dispatch(.click(section)) }
                    }
                    .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
                } else {
                    progress
                }
            }
//            .navigationTitle("Feed")
            .navigationBarItems(trailing: toolbarView)
//            .padding([.trailing, .leading], 12)
            .refreshable {
                await asyncUpdate()
            }
//        }
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
