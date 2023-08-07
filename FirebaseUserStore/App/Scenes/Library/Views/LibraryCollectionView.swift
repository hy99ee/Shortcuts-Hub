import SwiftUI
import Combine

struct LibraryCollectionView: View {
    @StateObject var store: LibraryStore

    @Binding var searchBinding: String

    @State private var showSearch = false
    @State private var isShowItems = false
    @State private var isShowLoadingItems = false
    @State private var isUpdating = false
    @State private var cellStyle: CollectionRowStyle = .row2

    private var columns: [GridItem] { Array(repeating: GridItem(.flexible()), count: cellStyle.rowCount) }
    private let progress = HDotsProgress()

    var body: some View {
        verticalGrid
    }
    
    private var verticalGrid: some View {
        NavigationView {
                ScrollView(showsIndicators: false) {
                    if let searchItems = store.state.searchedItems {
                        LazyVGrid(columns: columns) {
                            ForEach(0..<searchItems.count, id: \.self) { index in
                                ItemCellView(
                                    item: searchItems[index],
                                    cellStyle: cellStyle,
                                    isFromSelf: true
                                )
                                .padding(.vertical, 3)
                                .padding(.horizontal, 2)
                                .onTapGesture { store.dispatch(.click(searchItems[index])) }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let item = searchItems.at(index) {
                                            store.dispatch(.removeFromLibrary(item: item))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
                        }
                        .animation(.easeIn(duration: 0.3), value: store.state.searchedItems)
                    } else if let loadItems = store.state.loadItems {
                        LazyVGrid(columns: columns) {
                            ForEach(loadItems, id: \.id) {
                                LoaderFeedCellView(loaderItem: $0)
                                    .frame(height: cellStyle.rowHeight)
                                    .padding(.vertical, 3)
                                    .padding(.horizontal, 2)
                                    .opacity(isShowLoadingItems ? 1 : 0.5)
                                    .scaleEffect(isShowLoadingItems ? 1 : 0.8)
                                    .animation(.easeIn(duration: 0.4), value: isShowLoadingItems)
                            }
                        }
                        .modifier(StaticPreloaderViewModifier())
                        .onAppear { isShowLoadingItems = true }
                        .onDisappear { isShowLoadingItems = false }
                    } else {
                        LazyVGrid(columns: columns) {
                            ForEach(store.state.items) { item in
                                ItemCellView(
                                    item: item,
                                    cellStyle: cellStyle,
                                    isFromSelf: true
                                )
                                .overlay {
                                    if item == store.state.removingItem {
                                        ZStack {
                                            Color.red.opacity(0.5)
                                            ProgressView()
                                                .foregroundColor(.white)
//                                            HDotsProgress()
                                        }
                                        .cornerRadius(14)
                                    }
                                }
                                .padding(.vertical, 3)
                                .padding(.horizontal, 2)
                                .opacity(isShowItems ? 1 : 0.5)
                                .scaleEffect(isShowItems ? 1 : 0.8)
                                .animation(.easeIn(duration: 0.4), value: isShowItems)
                                .onTapGesture { store.dispatch(.click(item)) }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.dispatch(.removeFromLibrary(item: item))
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .onAppear {
                            isShowItems = true
                            showSearch = false
                            if store.state.items.count >= ItemsServiceQueryLimit
//                                        && index >= store.state.items.count - 1
                                && !isUpdating {
                                isUpdating = true
                                Task {
                                    await asyncNext()
                                }
                            }
                        }
                        .onDisappear { isShowItems = false }
                        .animation(.easeIn(duration: 0.3), value: store.state.items)
                        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
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

            if store.state.loginState == .loggedIn && !(store.state.isShowEmptyView ?? false) && !store.state.isShowErrorView {
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
