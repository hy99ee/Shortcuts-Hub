import SwiftUI

struct DetailSectionView: View {
    let section: IdsSection
    let onClose: () -> ()
    @State var detailScale: CGFloat = 1
    @State private var offset: CGFloat = .zero
    @State private var animation = true

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    var body: some View {
        OffsetObservingScrollView(scale: $detailScale) {
            Color.clear
                .frame(height: abs(offset / 2))

            VStack {
                ItemsSectionView.createSectionView(section: section)
                    .frame(height: 480)
                    .ignoresSafeArea()

                detailContent(section: section)
            }
            .cornerRadius(150 - detailScale * 140)
            .offset(y: offset)
        }
        .closeToolbar(onClose)
        .padding(.vertical)
        .edgesIgnoringSafeArea(.horizontal)
        .onChange(of: detailScale) {
            let offset = 25 - $0 * 25
            self.offset = -abs(offset * 100)
            print(offset)
            if $0 < 0.92 {
                onClose()
            }
        }
    }

    private func detailContent(section: IdsSection) -> some View {
        ZStack {
            Rectangle()

            ScrollView {
                VStack {
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                }
                VStack {
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                }
                VStack {
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                }
                VStack {
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                }
            }
            .foregroundColor(.blue)
        }
    }
}
