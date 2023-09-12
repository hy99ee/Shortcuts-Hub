import SwiftUI
import Combine

struct LibraryView: View {
    @StateObject var store: LibraryStore

    @State private var contentType: CollectionContent = .loading
    @State private var isShowSearchable = false

    private let searchQuery: CurrentValueSubject<String, Never>

    private var subscriptions = Set<AnyCancellable>()

    var searchBinding: Binding<String> {
        .init(
            get: { searchQuery.value },
            set: { searchQuery.send($0) }
        )
    }

    init(store: LibraryStore) {
        self._store = StateObject(wrappedValue: store)
        self.searchQuery = CurrentValueSubject<String, Never>(store.state.searchFilter)

        let search = searchQuery
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
        if store.state.loginState == .loggedOut {
            unloginUserView.toolbar { toolbarView }
        } else if store.state.loginState == .loading {
            unknownUserView.toolbar { toolbarView }
        } else {
            CollectionView(
                store: store,
                contentType: $contentType,
                searchBinding: searchBinding,
                isShowSearchable: $isShowSearchable
            )
            .onAppear { store.dispatch(.initLibrary) }
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
                } else if let loadingItems = newState.loadingItems {
                    contentType = .content(type: .default(status: .preload(loaders: loadingItems)))
                    isShowSearchable = !loadingItems.isEmpty
                } else if !store.state.items.isEmpty {
                    contentType = .content(type: .default(status: .loaded(items: store.state.items)))
                    isShowSearchable = true
                } else {
                    contentType = .loading
                    isShowSearchable = false
                }
            }
        }
    }

    private var unloginUserView: some View {
        Text("Unlogin")
            .bold()
            .onAppear() {
                if store.packages.sessionService.state != store.state.loginState {
                    store.dispatch(.userLoginState(store.packages.sessionService.state))
                }
            }
            .onChange(of: store.packages.sessionService.state) { newValue in
                store.dispatch(.userLoginState(newValue))
            }
    }

    private var unknownUserView: some View {
        Text("")
            .onAppear() {
                if store.packages.sessionService.state != store.state.loginState {
                    store.dispatch(.userLoginState(store.packages.sessionService.state))
                }
            }
            .onChange(of: store.packages.sessionService.state) { newValue in
                store.dispatch(.userLoginState(newValue))
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
}
