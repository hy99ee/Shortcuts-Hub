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
                ItemsSectionView(section: store.state.idsSection)
                    .equatable()
                    .environmentObject(namespaceWrapper)
//                    .frame(height: 460)
                    .scaleEffect(isShowDetailSection ? 1 : 0.9)
                    .zIndex(3)
                    .ignoresSafeArea()

                VStack {
                    detailContent(items: store.state.itemsFromSection)
                        .opacity(isShowDetailContent ? 1 : 0)
                        .offset(y: isShowDetailContent ? 0 : -100)
                }
                .modifier(ProgressViewModifier(progressStatus: store.state.viewProgress, backgroundOpacity: 0))
            }
            .cornerRadius(abs(150 - detailScale * 150))
        }
        .padding(.vertical)
        .edgesIgnoringSafeArea(.horizontal)
        .onChange(of: detailScale) {
            if $0 < 0.85 { store.dispatch(.close) }
        }
        .onAppear {
            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.6, blendDuration: 0.75)) {
                isShowDetailSection = true
            }
        }
        .onChange(of: store.state.viewProgress) {
            if $0 == .stop {
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.55, blendDuration: 0.7).delay(0.3)) {
                    isShowDetailContent = true
                }
            }
        }
        .closeToolbar {
            withAnimation(.spring().speed(1.2)) {
                detailScale = 0.85
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                store.dispatch(.close)
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
