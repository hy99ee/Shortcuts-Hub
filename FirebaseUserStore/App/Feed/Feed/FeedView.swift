import SwiftUI
import Combine


struct FeedView: View {
    @StateObject var store: FeedStore

    private let searchQueryBublisher = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()

    init(store: FeedStore) {
        self._store = StateObject(wrappedValue: store)

        searchQueryBublisher
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { $0.isEmpty ? store.dispatch(.updateFeed) : store.dispatch(.search(text: $0)) }
            .store(in: &subscriptions)
    }

    @State private var showLoader = false
    @State private var isRefresh = false

    var body: some View {
        mainView
    }
    
    var mainView: some View {
        VStack {
            VStack(alignment: .leading,
                   spacing: 16) {

                HStack {
                    Spacer()
                    Button {
                        store.dispatch(.showAboutSheet)
                    } label: {
                        Image(systemName: "person")
                    }
                }
                .padding()
            }
                   .padding(.horizontal, 16)

            if store.state.showEmptyView {
                VStack {
                    Spacer()
                    Image(systemName: "eyes").scaleEffect(3)
                        .padding()
                    ImageView(systemName: "arrow.triangle.2.circlepath") {
                        store.dispatch(.updateFeed)
                    }
                    .modifier(ButtonProgressViewModifier(provider: store.state.viewProgress, type: .clearView))
                    .padding()
                    Spacer()
                }
            } else {
                let searchBinding = Binding<String>(
                    get: { searchQueryBublisher.value },
                    set: { searchQueryBublisher.send($0) }
                  )
                SearchBar(searchQuery: searchBinding)
                FeedCollectionView(store: store, searchQuery: searchBinding)
            }

            ButtonView(title: "NEW") {
                store.dispatch(.addItem)
            }
            .modifier(ProcessViewModifier(provider: store.state.processViewProgress))
            .modifier(ButtonProgressViewModifier(provider: store.state.buttonProgress, type: .buttonView))
            .padding()
        }
        .modifier(AlertShowViewModifier(provider: store.state.alert))
        .modifier(SheetShowViewModifier(provider: store.state.aboutSheetProvider))
    }

    @ViewBuilder
    private func itemsCollection() -> some View {
        NavigationView {
            if store.state.itemsPreloadersCount == 0 {
                List {
                    ForEach(store.state.items) {
                        Text($0.title)
                    }
                    .onDelete {
                        let idsToDelete = $0.map { self.store.state.items[$0].id }
                        guard let id = idsToDelete.first else { return }
                        
                        store.dispatch(.removeItem(id: id))
                    }
                }
                .modifier(ProgressViewModifier(provider: store.state.viewProgress))
                .refreshable {
                    store.dispatch(.updateFeed)
                }
            } else {
                List {
                    ForEach(store.state.loadItems) { _ in
                        ProgressView()
                            .opacity(0.5)
                    }
                }
            }
        }
    }
}

extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}
