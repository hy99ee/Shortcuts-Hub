import SwiftUI
import Combine

struct LibraryCollectionView: View {
    @StateObject var store: LibraryStore

    @Binding var searchBinding: String

    @State private var isUpdating = false
    @State private var cellStyle: CollectionRowStyle = .row2

    @State private var contentType: FeedContent = .loading

    private var columns: [GridItem] { Array(repeating: GridItem(.flexible()), count: cellStyle.rowCount) }
    private let progress = HDotsProgress()

    var body: some View {
        NavigationView {
                ScrollView(showsIndicators: false) {
                    switch contentType {
                    case .content(let type):
                        switch type {
                        case .default(let status):
                            switch status {
                            case .loaded(let items): itemsView(items).transition(.opacity)
                            case .preload(let preload): loadedItemsView(preload).transition(.opacity)
                            case .none: EmptyView()
                            }

                        case .search(let status):
                            switch status {
                            case .loaded(let items): searchedItemsView(items).transition(.opacity)
                            case .preload(let preload): loadedItemsView(preload).transition(.opacity)
                            case .none: EmptyView()
                            }

                        }
                    case .empty(let type):
                        switch type {
                        case .default: Text("Empty")
                        case .search: Text("Empty search")
                        }
                    case .loading:
                        HDotsProgress()
                    }
                }
                .navigationTitle("Library")
                .navigationBarItems(trailing: toolbarView)
                .searchable(text: $searchBinding)
                .disableAutocorrection(true)
                .onSubmit(of: .search) { store.dispatch(.search(text: searchBinding)) }
                .padding([.trailing, .leading], 12)
                .refreshable { await asyncUpdate() }
        }
        .onChange(of: store.state) { newState in
            if let searchedItems = newState.searchedItems {
                withAnimation(.spring().speed(0.75)) {
                    self.contentType = .content(type: .search(status: .loaded(items: searchedItems)))
                }
            } else if let loadedItems = newState.preloadItems {
                withAnimation(.spring().speed(0.75)) {
                    self.contentType = .content(type: .default(status: .preload(loaders: loadedItems)))
                }
            } else {
                withAnimation(.spring().speed(0.75)) {
                    self.contentType = .content(type: .default(status: .loaded(items: store.state.items)))
                }
            }
        }
    }

    private func searchedItemsView(_ searchedItems: [Item]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(0..<searchedItems.count, id: \.self) { index in
                ItemCellView(
                    item: searchedItems[index],
                    cellStyle: cellStyle,
                    isFromSelf: true
                )
                .padding(.vertical, 3)
                .padding(.horizontal, 2)
                .onTapGesture { store.dispatch(.click(searchedItems[index])) }
                .contextMenu {
                    Button(role: .destructive) {
                        if let item = searchedItems.at(index) {
                            store.dispatch(.removeFromLibrary(item: item))
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
        .animation(.interactiveSpring().speed(0.75), value: store.state.searchedItems)
    }

    private func loadedItemsView(_ loadedItems: [LoaderItem]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(loadedItems, id: \.id) {
                LoaderFeedCellView(loaderItem: $0)
                    .frame(height: cellStyle.rowHeight)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 2)
            }
        }
        .modifier(StaticPreloaderViewModifier())
        .animation(.interactiveSpring().speed(0.75), value: store.state.searchedItems)
    }

    private func itemsView(_ items: [Item]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(items) { item in
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
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        .cornerRadius(14)
                    }
                }
                .padding(.vertical, 3)
                .padding(.horizontal, 2)
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
            if store.state.items.count >= ItemsServiceQueryLimit && !isUpdating {
                isUpdating = true
                Task { await asyncNext() }
            }
        }
        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
        .animation(.interactiveSpring().speed(0.75), value: store.state.items)
    }

    private var toolbarView: some View {
        HStack {
            Button {
                store.dispatch(.showAboutSheet)
            } label: {
                Image(systemName: "person")
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
