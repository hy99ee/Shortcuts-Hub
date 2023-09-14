import SwiftUI
import Combine

struct FeedCollectionView: View {
    @StateObject var store: FeedStore
    @Binding var clickedSection: IdsSection?
    @Binding var scrollToSection: IdsSection?
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

//    @State private var offset: CGFloat = 0
    @State private var isUpdating = false

//    @State private var clickedSectionIdScale: UUID?
//    @State private var clickedSectionIdOpacity: UUID?

    private let progress = HDotsProgress()

    var body: some View {
        verticalGrid
    }

    private var verticalGrid: some View {
        ScrollViewReader { value in
            ScrollView(showsIndicators: false) {
                if store.state.sections.count > 0 {
                    ForEach(store.state.sections) { section in
                        ItemsSectionView(section: section)
                            .equatable()
                            .environmentObject(namespaceWrapper)
                            .onTapGesture { store.dispatch(.click(section)) }
                            .cornerRadius(9)
                            .padding(.vertical)
                            .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
//                            .zIndex(section.id == scrollToSection?.id ? 100 : 0)
                            .matchedGeometryEffect(id: "section_\(section.id)", in: namespaceWrapper.namespace)
                            .id(section.id)
                    }
                } else {
                    progress
                }
            }
            .onAppear {
                if let id = scrollToSection?.id {
                    withAnimation {
                        value.scrollTo(id)
                    }
                }
            }
//            .offset(y: offset)
            .animationAdapted(animationDuration: 0.5)
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
