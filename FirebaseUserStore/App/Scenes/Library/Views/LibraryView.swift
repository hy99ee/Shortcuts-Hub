import SwiftUI
import Combine

struct LibraryView: View {
    @StateObject var store: LibraryStore

    private let searchQuery: CurrentValueSubject<String, Never>
    private var subscriptions = Set<AnyCancellable>()

    @State private var showLoader = false
    @State private var isRefresh = false
    @State private var errorLibraryDelay = false

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
        VStack {
            if store.state.loginState == .loading {
                unknownUserView.toolbar { toolbarView }
            } else if store.state.loginState == .loggedOut {
                unloginUserView.toolbar { toolbarView }
            } else if store.state.showEmptyView {
                emptyView.toolbar { toolbarView }
            } else if store.state.showErrorView {
                updateableErrorView.toolbar { toolbarView }
            } else {
                LibraryCollectionView(store: store, searchBinding: searchBinding)
            }
        }
        .onAppear { store.dispatch(.initLibrary) }
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

    private var emptyView: some View {
        Text("Empty").bold()
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
