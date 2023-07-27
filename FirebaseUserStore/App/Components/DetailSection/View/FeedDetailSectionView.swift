import SwiftUI

struct FeedDetailSectionView: View {
    @StateObject var store: FeedDetailSectionStore

    @State private var detailScale: CGFloat = 1
    @State var detailOffset: CGFloat = 0

    @State private var isShowDetailSection = false
    @State private var isShowDetailContent = false

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    var body: some View {
        OffsetObservingScrollView(scale: $detailScale, offset: $detailOffset) {
            VStack {
                ItemsSectionView(section: store.state.idsSection, isDetail: true)
                    .equatable()
                    .environmentObject(namespaceWrapper)
                    .scaleEffect(isShowDetailSection ? 1 : 0.96)
                    .matchedGeometryEffect(id: "section_\(store.state.idsSection.id)", in: namespaceWrapper.namespace, properties: .position)

                detailContent(items: store.state.itemsFromSection)
                detailContent(items: store.state.itemsFromSection)
                detailContent(items: store.state.itemsFromSection)
                detailContent(items: store.state.itemsFromSection)
                detailContent(items: store.state.itemsFromSection)
                detailContent(items: store.state.itemsFromSection)
                detailContent(items: store.state.itemsFromSection)
                detailContent(items: store.state.itemsFromSection)

            }
            .cornerRadius(abs(170 - detailScale * 170))
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: detailScale) {
            if $0 < 0.87 { store.dispatch(.close) }
        }
        .onAppear {
            withAnimation(.easeIn) {
                isShowDetailSection = true
            }
        }
        .applyClose {
            withAnimation(.easeInOut(duration: 0.3)) {
                detailScale = 0.87
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                store.dispatch(.close)
            }
        }
        .background {
            if isShowDetailSection {
                BlurView(style: .systemThickMaterial)
                    .ignoresSafeArea()
                    .animation(.linear(duration: 0.4), value: isShowDetailSection)
                    .transition(.opacity.animation(.linear(duration: 0.4)))
            }
        }
        .zIndex(1000)
    }

    @ViewBuilder private func detailContent(items: [Item]) -> some View {
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
}
