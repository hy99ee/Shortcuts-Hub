import SwiftUI
import Combine

struct SavedView: View {
    @StateObject var store: SavedStore

    @State private var contentType: CollectionContent = .loading
    @State private var isShowSearchable = false

    private let searchQueryBublisher: CurrentValueSubject<String, Never>
    private var subscriptions = Set<AnyCancellable>()

    var searchBinding: Binding<String> {
        .init(
            get: { searchQueryBublisher.value },
            set: { searchQueryBublisher.send($0) }
        )
    }

    init(store: SavedStore) {
        self._store = StateObject(wrappedValue: store)
        self.searchQueryBublisher = CurrentValueSubject<String, Never>(store.state.searchFilter)

        let search = searchQueryBublisher
            .removeDuplicates()
            .dropFirst()
            .flatMap {
                Just($0)
                .handleEvents(receiveOutput: { store.dispatch(.changeSearchField($0)) })
                .zip(store.objectWillChange)
                .map { $0.0 }
            }
            .share()

        search
            .filter { !$0.isEmpty }
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { store.dispatch(.search(text: $0)) }
            .store(in: &subscriptions)
    }

    var body: some View {
        CollectionView(
            store: store,
            contentType: $contentType,
            searchBinding: searchBinding,
            isShowSearchable: $isShowSearchable
        )
        .onAppear { store.dispatch(.initSaved) }
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
            } else if let loadedItems = newState.loadingItems {
                contentType = .content(type: .default(status: .preload(loaders: loadedItems)))
                isShowSearchable = true
            } else {
                contentType = .content(type: .default(status: .loaded(items: store.state.items)))
                isShowSearchable = true
            }
        }
    }
}
