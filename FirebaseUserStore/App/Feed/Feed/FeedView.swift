import SwiftUI
import Combine


struct FeedView: View {
    @EnvironmentObject var store: FeedStore
    @State var showLoader = false
    let heights = stride(from: 0.1, through: 1.0, by: 0.1).map { PresentationDetent.fraction($0) }
    
    @State var isRefresh = false
    let userDetailStore = SessionService.shared.userDetails

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
                FeedCollectionView(store: store)
            }

            ButtonView(title: "NEW") {
                store.dispatch(.addItem)
            }
            .modifier(ButtonProgressViewModifier(provider: store.state.buttonProgress, type: .buttonView))
            .modifier(ProcessViewModifier(provider: store.state.processViewProgress))
            .padding()
        }
        .modifier(AlertShowViewModifier(provider: store.state.alert))
        .modifier(SheetShowViewModifier(provider: store.state.aboutSheetProvider))
        
        .onAppear {
            store.dispatch(.updateFeed)
        }
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


struct FeedCollectionView: View {
    var store: FeedStore
    @State private var isAnimating = false

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    private let updateListener = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(store: FeedStore) {
        self.store = store

        self.store.$state
            .filter { $0.itemsPreloadersCount != 0 && !$0.items.isEmpty }
            .print("_STORE_STATE")
            .map { _ in () }
            .subscribe(updateListener)
            .store(in: &subscriptions)
    }

    var body: some View {
        NavigationView {
            if store.state.itemsPreloadersCount == 0 {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<store.state.items.count, id: \.self) { index in
                            FeedCellView(title: store.state.items[index].title)
                                .padding(3)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(.easeIn(duration: 0.7).delay(Double(index) * 0.03), value: isAnimating)
                        }
                    }
                }
                .modifier(ProgressViewModifier(provider: store.state.viewProgress))
                .refreshable {
                    await asyncUpdate()
                }
                .onAppear { isAnimating = true }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.state.loadItems, id: \.id) { _ in
                            LoaderFeedCellView()
                                .padding(3)
                        }
                    }
                }
                .modifier(FeedPreloaderProgressViewModifier())
                .onAppear { isAnimating = false }
            }
        }
        .padding(12)
        .cornerRadius(12)
    }

    func asyncUpdate() async -> Void {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            store.dispatch(.updateFeed)
        }
        try! await updateListener.eraseToAnyPublisher().async()
    }
}
