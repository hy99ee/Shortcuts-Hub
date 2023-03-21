import SwiftUI
import Combine

struct SavedCollectionView: View {
    @StateObject var store: SavedStore

    @Binding var searchBinding: String
    
    @State private var isAnimating = false
    @State private var isUpdating = false
    @State private var cellStyle: CollectionRowStyle = .row3

    private var columns: [GridItem] { Array(repeating: GridItem(.flexible()), count: cellStyle.rowCount) }
    private let progress = HDotsProgress()

    var body: some View {
        verticalGrid
    }
    
    private var verticalGrid: some View {
        NavigationView {
                ScrollView(showsIndicators: false) {
                    if let searchItems = store.state.searchedItems {
                        if searchItems.isEmpty {
                            Text("Empty search")
                                .padding(30)
                                .modifier(ProgressViewModifier(progressStatus: store.state.viewProgress, backgroundOpacity: 0))
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(0..<searchItems.count, id: \.self) { index in
                                    FeedCellView(
                                        item: searchItems[index],
                                        cellStyle: cellStyle
                                    )
                                    .padding(3)
                                    .onTapGesture {
                                        store.dispatch(.click(searchItems[index]))
                                    }
                                }
                            }
                        }
                    } else if let loadItems = store.state.loadItems {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(loadItems, id: \.id) { _ in
                                LoaderFeedCellView()
                                    .frame(height: cellStyle.rowHeight)
                                    .padding(3)
                            }
                        }
                        .modifier(StaticPreloaderViewModifier())
                        .onAppear { isAnimating = false }
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(0..<store.state.items.count, id: \.self) { index in
                                FeedCellView(
                                    item: store.state.items[index],
                                    cellStyle: cellStyle
                                )
                                .padding(3)
                                .opacity(isAnimating ? 1 : 0)
                                .scaleEffect(isAnimating ? 1 : 0.9)
                                .animation(.easeIn(duration: 0.7).delay((Double(index) + 0.5) * 0.03), value: isAnimating)
                                .onTapGesture {
                                    if let item = store.state.items.at(index) {
                                        store.dispatch(.click(item))
                                    }
                                }
                                .onAppear { isAnimating = true }
                            }
                        }
                        .animation(.spring().speed(0.8), value: store.state.items)
                        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
                    }
                }
                .navigationTitle("Saved")
                .searchable(text: $searchBinding)
                .disableAutocorrection(true)
                .onSubmit(of: .search) {
                    store.dispatch(.search(text: searchBinding))
                }
                .padding([.trailing, .leading], 12)
                .refreshable {
                    await asyncUpdate()
                }
        }
    }

    private func asyncUpdate() async -> Void {
        searchBinding.isEmpty ? store.dispatch(.updateSaved) : store.dispatch(.search(text: searchBinding))
        
        try? await self.store.objectWillChange
            .filter { self.store.state.viewProgress == .stop }
            .handleEvents(receiveOutput: { _ in isUpdating = false })
            .eraseToAnyPublisher()
            .async()
    }

    private func asyncNext() async -> Void {
        store.dispatch(.next)

        try? await self.store.objectWillChange
            .filter { self.store.state.viewProgress == .stop }
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .first()
            .handleEvents(receiveOutput: { _ in isUpdating = false })
            .eraseToAnyPublisher()
            .async()
    }
}
