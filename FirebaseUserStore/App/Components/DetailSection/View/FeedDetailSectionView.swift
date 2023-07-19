import SwiftUI

struct FeedDetailSectionView: View {
    @StateObject var store: FeedDetailSectionStore
    @State private var detailScale: CGFloat = 1

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    var body: some View {
        OffsetObservingScrollView(scale: $detailScale) {
            VStack {
//                ItemsSectionView.createSectionView(section: store.state.idsSection)
//                    .frame(height: 480)
//                    .ignoresSafeArea()
//
//                detailContent(items: store.state.itemsFromSection)
//                    .modifier(ProgressViewModifier(progressStatus: store.state.viewProgress, backgroundOpacity: 0))
                List {
                    Text("csadasda")
                    Text("csadasdqwdqwa")
                    Text("csadasda")
                    Text("csadasdqwdqwa")
                    Text("csadasda")
                    Text("csadasdqwdqwa")
                }
//                .zIndex(2)
            }
            .cornerRadius(150 - detailScale * 140)
        }
        .matchedGeometryEffect(id: store.state.idsSection.id, in: namespaceWrapper.namespace, isSource: false)
        .padding(.vertical)
        .edgesIgnoringSafeArea(.horizontal)
        .onChange(of: detailScale) {
            if $0 < 0.9 { store.dispatch(.close) }
        }
    }

    private func detailContent(items: [Item]) -> some View {
        ScrollView {
            if items.count > 0 {
                ForEach(items) { item in
                    ItemListView(item: item)
                        .onTapGesture {
                            store.dispatch(.open(item: item))
                        }
                }
            } else {
                Text("Empty")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.top, 30)
            }
        }
        .frame(minHeight: 100)
    }
}
