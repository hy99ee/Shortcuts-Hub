import SwiftUI

struct FeedDetailSectionView: View {
    @StateObject var store: FeedDetailSectionStore

    @State private var detailScale: CGFloat = 1
    @State private var offset: CGFloat = .zero

    @State private var isShowDetailSection = false
    @State private var isShowDetailContent = false

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    var body: some View {
        OffsetObservingScrollView(scale: $detailScale) {
            VStack {
                ItemsSectionView.createSectionView(section: store.state.idsSection, namespace: namespaceWrapper.namespace)
                    .frame(height: 480)
                    .scaleEffect(isShowDetailSection ? 1 : 0.9)
                    .zIndex(3)
                    .ignoresSafeArea()

                detailContent(items: store.state.itemsFromSection)
                    .modifier(ProgressViewModifier(progressStatus: store.state.viewProgress, backgroundOpacity: 0))
                    .opacity(isShowDetailContent ? 1 : 0.3)
                    .offset(y: isShowDetailContent ? 0 : -100)
            }
            .cornerRadius(abs(150 - detailScale * 150))
        }
        .padding(.vertical)
        .edgesIgnoringSafeArea(.horizontal)
        .onChange(of: detailScale) {
            if $0 <= 0.85 { store.dispatch(.close) }
        }
        .onAppear {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.75)) {
                isShowDetailSection = true
            }
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.55, blendDuration: 0.7).delay(0.3)) {
                isShowDetailContent = true
            }
        }
        .closeToolbar {
            withAnimation {
                detailScale = 0.85
            }
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
