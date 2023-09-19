import SwiftUI

struct FeedDetailSectionView: View {
    @StateObject var store: FeedDetailSectionStore

    @State private var detailScale: CGFloat = 1
    @State var detailOffset: CGPoint = .init()

    @State private var closeOffset: CGFloat = 0

    @State private var isShowDetailSection = false

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    var body: some View {
        OffsetObservingScrollView(offset: $detailOffset, scale: $detailScale) {
            VStack {
                ItemsSectionView(section: store.state.idsSection, isDetail: true)
                    .equatable()
                    .environmentObject(namespaceWrapper)
                    .scaleEffect(isShowDetailSection ? 1 : 0.96)

                detailContent(items: store.state.itemsFromSection)
                    .modifier(ProgressViewModifier(progressStatus: store.state.viewProgress, backgroundOpacity: 0))

            }
            .cornerRadius(abs(170 - detailScale * 170))
            .matchedGeometryEffect(id: "section_\(store.state.idsSection.id)", in: namespaceWrapper.namespace)
        }
        .offset(y: closeOffset)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: detailScale) {
            if $0 < 0.87 { store.dispatch(.close) }
        }
        .onAppear {
            withAnimation(.spring()) {
                isShowDetailSection = true
            }
        }
        .applyClose {
            withAnimation(.easeInOut(duration: 0.25)) {
                detailScale = 0.87
                closeOffset = 70
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
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
