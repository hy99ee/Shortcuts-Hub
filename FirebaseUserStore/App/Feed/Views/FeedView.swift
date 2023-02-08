import SwiftUI
import Combine

struct FeedView: View {
    @StateObject var store: FeedStore

    private let searchQueryBublisher = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()

    @State private var showLoader = false
    @State private var isRefresh = false
    @State private var errorFeedDelay = false

    init(store: FeedStore) {
        self._store = StateObject(wrappedValue: store)

        searchQueryBublisher
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { $0.isEmpty ? store.dispatch(.updateFeed) : store.dispatch(.search(text: $0)) }
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
                FeedCollectionView(store: store, searchQuery: searchBinding)
            }
        }
    }

    private func updateableErrorView() -> some View {
        VStack {
            Spacer()
            Text("Error").monospacedDigit().bold().foregroundColor(.red)
            ImageView(systemName: "arrow.triangle.2.circlepath") {
                withAnimation {
                    errorFeedDelay = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        errorFeedDelay = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            store.dispatch(.updateFeed)
                        }
                    }
                }
            }
            .modifier(ButtonProgressViewModifier(provider: store.state.viewProgress, type: .clearView))
            .disabled(errorFeedDelay)
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
}

extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}
