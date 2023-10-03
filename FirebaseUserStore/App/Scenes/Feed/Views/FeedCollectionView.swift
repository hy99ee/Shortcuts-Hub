import SwiftUI
import Combine

struct FeedCollectionView: View {
    @StateObject var store: FeedStore
    @Binding var clickedSection: IdsSection?
    @Binding var previousClickedSection: IdsSection?
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    @State private var isUpdating = false

    @State private var clickedSectionIdScale: UUID?
    @State private var clickedSectionIdOffset: UUID?
    @State private var clickedSectionIdOpacity: UUID?
    private let coordinateSpaceName = UUID()

    private let progress = HDotsProgress()

    var body: some View {
        verticalGrid
    }

    @ViewBuilder private var content: some View {
        if store.state.sections.count > 0 {
            LazyVStack {
                ForEach(store.state.sections) { section in
                    ItemsSectionView(section: section)
                        .equatable()
                        .scaleEffect(section.id == clickedSectionIdScale ? 0.97 : 1)
                        .opacity(section.id == clickedSectionIdOpacity ? 0 : 1)
                        .environmentObject(namespaceWrapper)
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.15)) {
                                clickedSectionIdScale = section.id
                                clickedSectionIdOffset = section.id
                                previousClickedSection = section
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.easeIn(duration: 0.1)) {
                                    clickedSectionIdScale = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                                    clickedSectionIdOpacity = section.id
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                                store.dispatch(.click(section))
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                clickedSectionIdOpacity = nil
                                clickedSectionIdScale = nil
                                clickedSectionIdOffset = nil
                            }

                        }
                        .cornerRadius(9)
                        .padding(.vertical)
                        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
                        .id(section.id)
                        .offset(y: section.id == clickedSectionIdOffset ? 10 : 0)
                        .matchedGeometryEffect(id: "section_\(section.id)", in: namespaceWrapper.namespace)
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
                    value.scrollTo(id)
                }
            }
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
