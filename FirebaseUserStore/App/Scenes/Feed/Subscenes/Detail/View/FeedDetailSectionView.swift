import SwiftUI

struct FeedDetailSectionView: View {
    @StateObject var store: FeedDetailSectionStore

    @State private var detailScale: CGFloat = 1
    @State private var offset: CGFloat = .zero
    @State private var animation = true

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    var body: some View {
        OffsetObservingScrollView(scale: $detailScale) {
            Color.clear
                .frame(height: abs(offset / 2))

            VStack {
                ItemsSectionView.createSectionView(section: store.state.idsSection)
                    .frame(height: 480)
                    .ignoresSafeArea()

                detailContent(items: store.state.itemsFromSection)
                    .modifier(ProgressViewModifier(progressStatus: store.state.viewProgress, backgroundOpacity: 0))
            }
            .cornerRadius(150 - detailScale * 140)
            .offset(y: offset)
        }
        .padding(.vertical)
        .edgesIgnoringSafeArea(.horizontal)
        .onChange(of: detailScale) {
            let offset = 25 - $0 * 25
            self.offset = -abs(offset * 100)
            print(offset)
            if $0 < 0.9 {
                store.dispatch(.close)
            }
        }
    }

    private func detailContent(items: [Item]) -> some View {
        ScrollView {
            ForEach(items) {
                ItemCellView(item: $0, cellStyle: .row1)
            }
        }
        .frame(minHeight: 100)
    }
}
