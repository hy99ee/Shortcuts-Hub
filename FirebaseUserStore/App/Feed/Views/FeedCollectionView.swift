import SwiftUI

struct FeedCollectionView: View {
    let store: FeedStore

    @Binding var searchQuery: String
    @State private var isAnimating = false
    let cellStyle: CollectionRowStyle

    private var columns: [GridItem] { Array(repeating: GridItem(.flexible()), count: cellStyle.rowCount) }
    private let progress = HDotsProgress()


    var body: some View {
        NavigationView {
            if store.state.items.count != 0 {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<store.state.items.count, id: \.self) { index in
//                            FeedCellView(cellStyle: $cellStyle, title: store.state.items[index].title)
                            Rectangle()
                                .background(.red)
                                .foregroundColor(.red)
                                .cornerRadius(14)
                            .onTapGesture {
                                store.dispatch(.click(store.state.items[index]))
                            }
                            .padding(3)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.easeIn(duration: 0.7).delay(Double(index) * 0.03), value: isAnimating)
                        }
                    }
                }
                .modifier(AnimationProgressViewModifier(provider: store.state.viewProgress))
                .refreshable {
                    await asyncUpdate()
                }
                .onAppear {
                    isAnimating = true
                }
            } else if store.state.loadItems.count != 0 {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.state.loadItems, id: \.id) { _ in
                            LoaderFeedCellView()
                                .frame(height: cellStyle.rowHeight)
                                .padding(3)
                        }
                    }
                }
                .modifier(StaticPreloaderViewModifier())
                .onAppear { isAnimating = false }
            }
        }
        .padding(12)
        .cornerRadius(22)
    }

    func asyncUpdate() async -> Void {
        searchQuery.isEmpty ? store.dispatch(.updateFeed) : store.dispatch(.search(text: searchQuery))

        try? await self.store.objectWillChange
            .filter { self.store.state.viewProgress.progressStatus == .stop }
            .eraseToAnyPublisher()
            .async()
    }
}
