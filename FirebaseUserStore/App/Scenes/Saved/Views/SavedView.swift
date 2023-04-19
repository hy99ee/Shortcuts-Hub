import SwiftUI
import Combine

struct SavedView: View {
    @StateObject var store: SavedStore

    private let searchQueryBublisher: CurrentValueSubject<String, Never>
    private var subscriptions = Set<AnyCancellable>()

    @State private var showLoader = false
    @State private var isRefresh = false
    @State private var errorSavedDelay = false

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
        VStack {
            if let showEmpty = store.state.showEmptyView, showEmpty {
                emptyView
            } else if let showError = store.state.showErrorView, showError {
                updateableErrorView
            } else if store.state.showErrorView == nil, store.state.showEmptyView == nil {
                Text("")
                    .modifier(ProgressViewModifier(progressStatus: store.state.viewProgress, backgroundOpacity: 0))
            } else {
                SavedCollectionView(store: store, searchBinding: searchBinding)
            }
        }
        .onAppear { store.dispatch(.initSaved) }
    }

    private var updateableErrorView: some View {
        VStack {
            Spacer()
            Text("Error").monospacedDigit().bold().foregroundColor(.red)
            ImageView(systemName: "arrow.triangle.2.circlepath") {
                withAnimation {
                    errorSavedDelay = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        errorSavedDelay = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            store.dispatch(.updateSaved)
                        }
                    }
                }
            }
            .modifier(ButtonProgressViewModifier(progressStatus: store.state.viewProgress, type: .clearView))
            .disabled(errorSavedDelay)
            .padding()
            
            Spacer()
        }
    }

    private var emptyView: some View {
//        VStack {
//            Spacer()
            Text("Empty").bold()
//            Spacer()
//        }
    }

    private var unloginUserView: some View {
        VStack {
            Spacer()
            Text("Unlogin").bold()
            Spacer()
        }
    }

    private var loadingView: some View {
        VStack {
//            Spacer()
            HDotsProgress()
//            Spacer()
        }
    }
}
