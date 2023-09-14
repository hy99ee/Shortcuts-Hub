import SwiftUI
import Combine

struct FeedView: View {
    @StateObject var store: FeedStore
    @Binding var clickedSection: IdsSection?
    @Binding var scrollToSection: IdsSection?

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    @State private var showLoader = false
    @State private var isRefresh = false
    @State private var errorFeedDelay = false

    var body: some View {
        VStack {
            if store.state.isShowEmptyView {
                emptyView.toolbar { emptyToolbarView }
            } else if store.state.isShowErrorView {
                updateableErrorView.toolbar { errorToolbarView }
            } else {
                FeedCollectionView(
                    store: store,
                    clickedSection: $clickedSection,
                    scrollToSection: $scrollToSection
                )
                .environmentObject(namespaceWrapper)
                .toolbar { toolbarView }
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

    private var emptyToolbarView: some View {
        HStack {

        }
    }

    private var errorToolbarView: some View {
        HStack {

        }
    }

    private var toolbarView: some View {
        HStack {

        }
    }
}


extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}
