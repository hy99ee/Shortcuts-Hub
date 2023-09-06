import SwiftUI
import Combine

struct LibraryCollectionView: View {
    @StateObject var store: LibraryStore

    @Binding var searchBinding: String

    @State private var isUpdating = false
    @State private var cellStyle: CollectionRowStyle = .row2

    @State private var errorLibraryDelay = false

    @State private var contentType: FeedContent = .loading
    @State private var isShowSearchable = false

    private let appearAnimationOffset: CGFloat = 50

    private var columns: [GridItem] { Array(repeating: GridItem(.flexible()), count: cellStyle.rowCount) }
    private let progress = HDotsProgress()

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                if isShowSearchable {
                    scrollContent
                        .searchable(text: $searchBinding, placement: .navigationBarDrawer(displayMode: .automatic))
                        .disableAutocorrection(true)
                        .onSubmit(of: .search) { store.dispatch(.search(text: searchBinding)) }
                        .transition(.opacity)
                } else {
                    scrollContent
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.spring().speed(0.9), value: contentType)
            .navigationTitle("Library")
            .navigationBarItems(trailing: toolbarView)
            .padding([.trailing, .leading], 12)
            .refreshable { await asyncUpdate() }
            .onChange(of: store.state) { newState in
                if newState.isShowErrorView ?? false {
                    contentType = .error(type: .default(status: nil))
                    isShowSearchable = false
                } else if newState.isShowEmptyView ?? false {
                    contentType = .empty(type: .default(status: nil))
                    isShowSearchable = false
                } else if newState.isShowEmptySearchView ?? false {
                    contentType = .empty(type: .search(status: nil))
                    isShowSearchable = true
                } else if let searchedItems = newState.searchedItems {
                    contentType = .content(type: .search(status: .loaded(items: searchedItems)))
                    isShowSearchable = true
                } else if let loadedItems = newState.preloadItems {
                    contentType = .content(type: .default(status: .preload(loaders: loadedItems)))
                    isShowSearchable = true
                } else {
                    contentType = .content(type: .default(status: .loaded(items: store.state.items)))
                    isShowSearchable = true
                }
            }
        }
    }

    @ViewBuilder private var scrollContent: some View {
        switch contentType {
        case .content(let type):
            switch type {
            case .`default`(let status):
                switch status {
                case .loaded(let items):
                    itemsView(items)
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                        .frame(maxWidth: .infinity)
                case .preload(let preload):
                    loadedItemsView(preload)
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                        .frame(maxWidth: .infinity)
                case .none:
                    Text("")
                }

            case .search(let status):
                switch status {
                case .loaded(let items):
                    searchedItemsView(items)
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                        .frame(maxWidth: .infinity)
                case .preload(let preload):
                    loadedItemsView(preload)
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                        .frame(maxWidth: .infinity)
                case .none:
                    Text("")
                }
            }

        case .empty(let type):
            switch type {
            case .`default`:
                CollectionViewEmpty(errorMessage: "Empty")
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .offset(y: appearAnimationOffset)),
                            removal: .opacity.combined(with: .offset(y: appearAnimationOffset))
                        )
                    )
                    .frame(maxWidth: .infinity, idealHeight: 500)
            case .search:
                CollectionViewEmpty(errorMessage: "Empty search")
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .offset(y: appearAnimationOffset)),
                            removal: .opacity.combined(with: .offset(y: appearAnimationOffset))
                        )
                    )
                    .frame(maxWidth: .infinity, idealHeight: 500)
            }

        case .error(type: _):
            updateableErrorView
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: appearAnimationOffset)),
                        removal: .opacity.combined(with: .offset(y: appearAnimationOffset))
                    )
                )
                .frame(maxWidth: .infinity)

        case .loading:
            HDotsProgress()
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: appearAnimationOffset)),
                        removal: .opacity
                    )
                )
                .frame(maxWidth: .infinity)
        }
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
        .animation(.interactiveSpring().speed(0.8), value: store.state.searchedItems)
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
                    if store.state.itemsRemovingQueue.contains(item.id) {
                        ZStack {
                            Color.red.opacity(0.5)
                                .modifier(StaticPreloaderViewModifier())
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
                .onAppear {
                    if store.state.items.count >= ItemsServiceQueryLimit && !isUpdating {
                        isUpdating = true
                        Task { await asyncNext() }
                    }
                }
            }
        }

        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
        .animation(.interactiveSpring().speed(0.8), value: store.state.items)
    }

    private func searchedItemsView(_ searchedItems: [Item]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(searchedItems) { item in
                ItemCellView(
                    item: item,
                    cellStyle: cellStyle,
                    isFromSelf: true
                )
                .overlay {
                    if store.state.itemsRemovingQueue.contains(item.id) {
                        ZStack {
                            Color.red.opacity(0.4)
                                .modifier(StaticPreloaderViewModifier())
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
        .modifier(AnimationProgressViewModifier(progressStatus: store.state.viewProgress))
        .animation(.interactiveSpring().speed(0.75), value: store.state.searchedItems)
    }

    private var updateableErrorView: some View {
        VStack {
            Spacer()
            Text("Error").monospacedDigit().bold().foregroundColor(.red)
            ImageView(systemName: "arrow.triangle.2.circlepath") {
                withAnimation {
                    errorLibraryDelay = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        errorLibraryDelay = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            store.dispatch(.updateLibrary)
                        }
                    }
                }
            }
            .modifier(ButtonProgressViewModifier(progressStatus: store.state.viewProgress, type: .clearView))
            .disabled(errorLibraryDelay)
            .padding()

            Spacer()
        }
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

struct CollectionViewEmpty: View {
    let errorMessage: String

    var body: some View {
        VStack {
            Spacer()
            Image("EmptyIcon")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()

            Text(errorMessage)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
            Spacer()
        }
    }
}
