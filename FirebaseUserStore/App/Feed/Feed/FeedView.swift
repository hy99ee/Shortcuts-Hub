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
            .debounce(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { $0.isEmpty ? store.dispatch(.updateFeed) : store.dispatch(.search(text: $0)) }
            .store(in: &subscriptions)
    }

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
                    Text("Empty").bold()
                    Spacer()
                }
            } else if store.state.showErrorView {
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
                    .opacity(errorFeedDelay ? 0.3 : 1)
                    .disabled(errorFeedDelay)
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
}

extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}
