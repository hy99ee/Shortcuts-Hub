import SwiftUI
import Combine

struct LibraryView: View {
    @StateObject var store: LibraryStore

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
            LibraryCollectionView(store: store, searchBinding: searchBinding)
                .onAppear { store.dispatch(.initLibrary) }
        }
    }

    private var unloginUserView: some View {
        Text("Unlogin").bold()
    }

    private var unknownUserView: some View {
        Text("")
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
