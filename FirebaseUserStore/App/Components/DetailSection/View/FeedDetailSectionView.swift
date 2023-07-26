import SwiftUI

struct FeedDetailSectionView: View {
    @StateObject var store: FeedDetailSectionStore

    @State private var detailScale: CGFloat = 1

    @State private var isShowDetailSection = false
    @State private var isShowDetailContent = false

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    var body: some View {
        OffsetObservingScrollView(scale: $detailScale) {
            VStack {
                ItemsSectionView(section: store.state.idsSection, isDetail: true)
                    .equatable()
                    .environmentObject(namespaceWrapper)
                    .scaleEffect(isShowDetailSection ? 1 : 0.96)
                    .matchedGeometryEffect(id: "section_\(store.state.idsSection.id)", in: namespaceWrapper.namespace)

                detailContent(items: store.state.itemsFromSection)
                    .modifier(ProgressViewModifier(progressStatus: store.state.viewProgress, backgroundOpacity: 0))
                    .zIndex(-1)
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
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
            }
        }
        .zIndex(1000)
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
