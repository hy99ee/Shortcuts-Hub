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

    var searchBinding: Binding<String> {
        .init(
            get: { searchQueryBublisher.value },
            set: { searchQueryBublisher.send($0) }
        )
    }

    init(store: LibraryStore) {
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

        search
            .filter { $0.isEmpty }
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .map { _ in }
            .sink { store.dispatch(.updateLibrary) }
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
                LibraryCollectionView(store: store, cellStyle: collectionRowStyle, toolbarView: AnyView(toolbarView), searchBinding: searchBinding)
            }
        }
        .onAppear {
            if store.state.items.isEmpty { store.dispatch(.updateLibrary) }
        }
        .onChange(of: store.state.searchFilter) {
            if $0 != searchQueryBublisher.value {
                searchQueryBublisher.send($0)
            }
        }
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
                ImageView(systemName: collectionRowStyle.systemImage, size: collectionRowStyle.systemImageSize) {
                    withAnimation(.easeIn(duration: 0.6)) {
                        collectionRowStyle = collectionRowStyle.next()
                    }
                }
            }
        }
    }
}
