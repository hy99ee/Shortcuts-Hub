import SwiftUI
import Combine

struct CollectionView<T: CollectionDelegate>: View {
    @StateObject var store: T

    @Binding var contentType: CollectionContent
    @Binding var searchBinding: String
    @Binding var isShowSearchable: Bool

    @State private var isUpdating = false
    @State private var cellStyle: CollectionRowStyle = .row2

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
                        .onSubmit(of: .search) { Task { await store.search(searchBinding) } }
                        .transition(.opacity)
                } else {
                    scrollContent
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(store.navigationTitle)
            .navigationBarItems(trailing: toolbarView)
            .padding([.trailing, .leading], 12)
            .refreshable { await asyncUpdate() }
        }
        .animation(.spring(), value: contentType)
    }

    @ViewBuilder private var scrollContent: some View {
        switch contentType {
        case .content(let type):
            switch type {
            case .`default`(let status):
                switch status {
                case .loaded(let items):
                    itemsView(items)
                        .transition(
                            .asymmetric(
                                insertion: .opacity,
                                removal: .opacity.combined(with: .offset(y: -appearAnimationOffset))
                            )
                        )
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
                        .transition(
                            .asymmetric(insertion: .opacity, removal: .identity)
                        )
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
                CollectionErrorView(message: "Empty", status: store.viewProgress) {
                    Task { await store.update() }
                }
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: appearAnimationOffset)),
                        removal: .opacity.combined(with: .offset(y: appearAnimationOffset))
                    )
                )
                .frame(maxWidth: .infinity, idealHeight: 400)
            case .search:
                CollectionErrorView(message: "Empty search", status: store.viewProgress) {
                    Task { await store.update() }
                }
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: appearAnimationOffset)),
                        removal: .opacity.combined(with: .offset(y: appearAnimationOffset))
                    )
                )
                .frame(maxWidth: .infinity, idealHeight: 400)
            }

        case .error(type: _):
            CollectionErrorView(message: "Error", status: store.viewProgress) {
                Task { await store.update() }
            }
            .transition(
                .asymmetric(
                    insertion: .opacity.combined(with: .offset(y: appearAnimationOffset)),
                    removal: .opacity.combined(with: .offset(y: appearAnimationOffset))
                )
            )
            .frame(maxWidth: .infinity, idealHeight: 400)

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
        .animation(.spring(), value: store.preloadItems)
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
                    if store.isItemRemoving(item) {
                        ZStack {
                            Color.red.opacity(0.5)
                                .modifier(StaticPreloaderViewModifier())
                        }
                        .cornerRadius(14)
                    }
                }
                .padding(.vertical, 3)
                .padding(.horizontal, 2)
                .onTapGesture { store.click(item) }
                .contextMenu {
                    Button(role: .destructive) {
                        store.remove(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
//                .onAppear {
//                    if store.items.count >= ItemsServiceQueryLimit && !isUpdating {
//                        isUpdating = true
//                        Task { await asyncNext() }
//                    }
//                }
            }
        }
        .modifier(AnimationProgressViewModifier(progressStatus: store.viewProgress))
        .animation(.spring(), value: store.items)
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
                    if store.isItemRemoving(item) {
                        ZStack {
                            Color.red.opacity(0.4)
                                .modifier(StaticPreloaderViewModifier())
                        }
                        .cornerRadius(14)
                    }
                }
                .padding(.vertical, 3)
                .padding(.horizontal, 2)
                .onTapGesture { store.click(item) }
                .contextMenu {
                    Button(role: .destructive) {
                        store.remove(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .modifier(AnimationProgressViewModifier(progressStatus: store.viewProgress))
        .animation(.spring(), value: store.searchedItems)
    }

    private func asyncUpdate() async -> Void {
        await searchBinding.isEmpty ? store.update() : store.search(searchBinding)
    }

    private func asyncNext() async -> Void {
        await store.next()
    }

    private var toolbarView: some View {

        HStack {
            ForEach(store.toolbarItems) { item in
                Button {
                    item.action()
                } label: {
                    Image(systemName: item.iconName)
                }
            }
        }
    }
}

