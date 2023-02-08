import SwiftUI
import Combine

struct LibraryView: View {
    @StateObject var store: LibraryStore

    private let searchQueryBublisher = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()

    @State private var showLoader = false
    @State private var isRefresh = false
    @State private var errorLibraryDelay = false

    @State private var collectionRowStyle: CollectionRowStyle = .row3

    init(store: LibraryStore) {
        self._store = StateObject(wrappedValue: store)

        searchQueryBublisher
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { $0.isEmpty ? store.dispatch(.updateLibrary) : store.dispatch(.search(text: $0)) }
            .store(in: &subscriptions)
    }

    var body: some View {
        VStack {
            if store.state.showEmptyView {
                emptyView()
            } else if store.state.showErrorView {
                updateableErrorView()
            } else {
                let searchBinding = Binding<String>(
                    get: { searchQueryBublisher.value },
                    set: { searchQueryBublisher.send($0) }
                )
                SearchBar(searchQuery: searchBinding)
                LibraryCollectionView(store: store, searchQuery: searchBinding, cellStyle: collectionRowStyle)
            }
        }
        .toolbar { toolbarView() }
    }

    private func updateableErrorView() -> some View {
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

    private func emptyView() -> some View {
        return VStack {
            Spacer()
            Text("Empty").bold()
            Spacer()
        }
    }

    private func toolbarView() -> some View {
        HStack {
            ImageView(systemName: "person", size: 18) {
                store.dispatch(.showAboutSheet)
            }
            .padding([.leading, .trailing], 8)

            ImageView(systemName: "plus", size: 20) {
                store.dispatch(.addItem)
            }
            .modifier(ProcessViewModifier(provider: store.state.processView))
            .modifier(ButtonProgressViewModifier(provider: store.state.buttonProgress, type: .clearView))
            .padding([.leading, .trailing], 8)

            ImageView(systemName: collectionRowStyle.next().systemImage, size: collectionRowStyle.next().systemImageSize) {
                withAnimation(.easeIn(duration: 0.6)) {
                    collectionRowStyle = collectionRowStyle.next()
                }
            }
        }
    }

}
