import SwiftUI
import Combine

struct LibraryCollectionView: View {
    @StateObject var store: LibraryStore

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
                                    FeedCellView(title: searchItems[index].title, cellStyle: cellStyle) {
                                        store.dispatch(.removeItem(id: searchItems[index].id))
                                    }
                                    .onTapGesture {
                                        store.dispatch(.click(searchItems[index]))
                                    }
                                }
                            }
                            .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
                        }
                    } else if !store.state.items.isEmpty {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(0..<store.state.items.count, id: \.self) { index in
                                FeedCellView(title: store.state.items[index].title, cellStyle: cellStyle) {
                                    store.dispatch(.removeItem(id: store.state.items[index].id))
                                }
                                .padding(3)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(.easeIn(duration: 0.7).delay(Double(index) * 0.03), value: isAnimating)
                                .onTapGesture {
                                    store.dispatch(.click(store.state.items[index]))
                                }
                                .onAppear {
                                    if store.state.items.count >= ItemsServiceQueryLimit
                                        && index >= store.state.items.count - 1
                                        && !isUpdating {
                                        isUpdating = true
                                        Task {
                                            await asyncNext()
                                        }
                                    }
                                }
                            }
                        }
                        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
                        .onAppear { isAnimating = true }
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
                    }
                }
                .navigationTitle("Library")
                .navigationBarItems(trailing: toolbarView)
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
    
    private var toolbarView: some View {
        HStack {
            Button {
                store.dispatch(.showAboutSheet)
            } label: {
                Image(systemName: "person")
            }

            if store.state.loginState == .loggedIn && !store.state.showEmptyView && !store.state.showErrorView {
                Button {
                    withAnimation(.easeIn(duration: 0.6)) {
                        cellStyle = cellStyle.next()
                    }
                } label: {
                    Image(systemName: cellStyle.systemImage)
                }
            }
        }
    }

    private func asyncUpdate() async -> Void {
        searchBinding.isEmpty ? store.dispatch(.updateLibrary) : store.dispatch(.search(text: searchBinding))
        
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
