import SwiftUI
import Combine

struct FeedView: View {
    @StateObject var store: FeedStore
    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

//    private let searchQueryBublisher: CurrentValueSubject<String, Never>
//    private var subscriptions = Set<AnyCancellable>()

    @State private var showLoader = false
    @State private var isRefresh = false
    @State private var errorFeedDelay = false

//    var searchBinding: Binding<String> {
//        .init(
//            get: { searchQueryBublisher.value },
//            set: { searchQueryBublisher.send($0) }
//        )
//    }

//    init(store: FeedStore) {
//        self._store = StateObject(wrappedValue: store)
//        self.searchQueryBublisher = CurrentValueSubject<String, Never>(store.state.searchFilter)
//
//        let search = searchQueryBublisher
//            .removeDuplicates()
//            .dropFirst()
//            .flatMap {
//                Just($0)
//                .handleEvents(receiveOutput: { store.dispatch(.changeSearchField($0)) })
//                .zip(store.objectWillChange)
//                .map { $0.0 }
//            }
//            .share()
//
//        search
//            .filter { !$0.isEmpty }
//            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
//            .sink { store.dispatch(.search(text: $0)) }
//            .store(in: &subscriptions)
//    }
    var body: some View {
        VStack {
            if store.state.showEmptyView {
                emptyView.toolbar { toolbarView }
            } else if store.state.showErrorView {
                updateableErrorView.toolbar { toolbarView }
            } else {
                FeedCollectionView(store: store)
                    .environmentObject(namespaceWrapper)
            }
        }
        .onAppear { store.dispatch(.initFeed) }
    }

    private var updateableErrorView: some View {
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
            .modifier(ButtonProgressViewModifier(progressStatus: store.state.viewProgress, type: .clearView))
            .disabled(errorFeedDelay)
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

        }
    }
}


extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}
