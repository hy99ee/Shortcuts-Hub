import SwiftUI
import Combine

struct LibraryView: View {
    @StateObject var store: LibraryStore

    private let searchQueryBublisher: CurrentValueSubject<String, Never>
    private var subscriptions = Set<AnyCancellable>()

    @State private var showLoader = false
    @State private var isRefresh = false
    @State private var errorLibraryDelay = false

    @State private var collectionRowStyle: CollectionRowStyle = .row3

    init(store: LibraryStore) {
        self._store = StateObject(wrappedValue: store)
        self.searchQueryBublisher = CurrentValueSubject<String, Never>(store.state.searchFilter)

        searchQueryBublisher
            .removeDuplicates()
            .dropFirst()
            .handleEvents(receiveOutput: { store.dispatch(.changeSearchField($0)) })
            .debounce(for: .seconds(store.state.searchFilter.isEmpty ? 0 : 1), scheduler: DispatchQueue.main)
            .sink { _ in
                store.dispatch(.updateLibrary)
            }
            .store(in: &subscriptions)
    }

    var body: some View {
        VStack {
            if store.state.loginState == .loading {
                unknownUserView
            } else if store.state.loginState == .loggedOut {
                unloginUserView
            } else if store.state.showEmptyView {
                emptyView
            } else if store.state.showErrorView {
                updateableErrorView
            } else {
                let searchBinding = Binding<String>(
                    get: { searchQueryBublisher.value },
                    set: {
                        searchQueryBublisher.send($0)
//                        store.objectWillChange.send()
                    }
                )
                SearchBar(searchQuery: searchBinding)
                LibraryCollectionView(store: store, searchQuery: searchBinding, cellStyle: collectionRowStyle)
            }
        }
        .onAppear {
//            if store.state.items.isEmpty {
//                searchQueryBublisher.value.isEmpty
                store.dispatch(.updateLibrary)
//                : store.dispatch(.search(text: searchQueryBublisher.value))
//            }
        }
        .toolbar { toolbarView }
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
//                            searchQueryBublisher.value.isEmpty
                            store.dispatch(.updateLibrary)
//                            : store.dispatch(.search(text: searchQueryBublisher.value))
                        }
                    }
                }
            }
            .modifier(ButtonProgressViewModifier(provider: store.state.viewProgress, type: .clearView))
            .disabled(errorLibraryDelay)
            .padding()
            
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            Text("Empty").bold()
            Spacer()
        }
    }

    private var unloginUserView: some View {
        VStack {
            Spacer()
            Text("Unlogin").bold()
            Spacer()
        }
    }

    private var unknownUserView: some View {
        EmptyView()
    }

    private var toolbarView: some View {
        HStack {
            ImageView(systemName: "person", size: 18) {
                store.dispatch(.showAboutSheet)
            }
            .padding([.leading, .trailing], 8)

            if store.state.loginState == .loggedIn {
                ImageView(systemName: collectionRowStyle.next().systemImage, size: collectionRowStyle.next().systemImageSize) {
                    withAnimation(.easeIn(duration: 0.6)) {
                        collectionRowStyle = collectionRowStyle.next()
                    }
                }
            }
        }
    }
}
