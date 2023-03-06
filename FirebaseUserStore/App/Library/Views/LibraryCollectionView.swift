import SwiftUI

struct LibraryCollectionView: View {
    let store: LibraryStore
    let cellStyle: CollectionRowStyle
    let toolbarView: AnyView
    
    @Binding var searchBinding: String
    
    @State private var isAnimating = false
    @State private var isUpdating = false

    private var columns: [GridItem] { Array(repeating: GridItem(.flexible()), count: cellStyle.rowCount) }
    private let progress = HDotsProgress()
    
    var body: some View {
        verticalGrid
    }
    
    private var verticalGrid: some View {
        NavigationView {
                ScrollView(showsIndicators: false) {
                    if !store.state.items.isEmpty {
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
                                        && index >= store.state.items.count - 10
                                        && !isUpdating {
                                        isUpdating = true
                                        Task {
                                            await asyncNext()
                                        }
                                    }
                                }
                            }
                        }
                        .modifier(AnimationProgressViewModifier(provider: store.state.viewProgress))
                        .onAppear { isAnimating = true }
                    } else if !store.state.loadItems.isEmpty {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(store.state.loadItems, id: \.id) { _ in
                                LoaderFeedCellView()
                                    .frame(height: cellStyle.rowHeight)
                                    .padding(3)
                            }
                        }
                        .modifier(StaticPreloaderViewModifier())
                        .onAppear { isAnimating = false }
                    } else if store.state.items.isEmpty
                                && !store.state.searchFilter.isEmpty
                                && store.state.viewProgress.progressStatus == .stop {
                            Text("Empty search")
                    }
                }
                .navigationTitle("Library")
                .navigationBarItems(trailing: toolbarView)
                .toolbarBackground(Color.white, for: .navigationBar)
                .searchable(text: $searchBinding)
                .disableAutocorrection(true)
                .padding([.trailing, .leading], 12)
                .refreshable {
                    await asyncUpdate()
                }
        }
    }
    
    //    private var horizontalGrid: some View {
    //        TabView(selection: $lastIndex) {
    //            ForEach(0..<store.state.items.count, id: \.self) { index in
    //                FeedCellView(title: store.state.items[index].title, cellStyle: cellStyle) {
    //                    store.dispatch(.removeItem(id: store.state.items[index].id))
    //                }
    //                .padding([.leading])
    //                .scaleEffect(0.9)
    //            }
    //        }
    //
    //        .shadow(color: .secondary, radius: 20)
    //        .matchedGeometryEffect(id: lastIndex, in: morphSeamlessly)
    //        .scaleEffect(scaleDetail)
    //        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    //        .onTapGesture {
    //            withAnimation(.spring(response: 0.55, dampingFraction: 0.5, blendDuration: 0)) {
    //                scaleDetail = 0
    //            }
    //        }
    //        .onChange(of: lastIndex) { _ in
    //            needScrollVertical = true
    //        }
    //        .padding([.trailing])
    //    }
    
    private func asyncUpdate() async -> Void {
        searchBinding.isEmpty ? store.dispatch(.updateLibrary) : store.dispatch(.search(text: searchBinding))
        
        try? await self.store.objectWillChange
//            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .filter { self.store.state.viewProgress.progressStatus == .stop }
            .handleEvents(receiveOutput: { _ in isUpdating = false })
            .eraseToAnyPublisher()
            .async()
    }

    private func asyncNext() async -> Void {
        store.dispatch(.next(text: searchBinding))

        try? await self.store.objectWillChange
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .filter { self.store.state.viewProgress.progressStatus == .stop }
            .first()
            .handleEvents(receiveOutput: { _ in isUpdating = false })
            .eraseToAnyPublisher()
            .async()
    }
}
