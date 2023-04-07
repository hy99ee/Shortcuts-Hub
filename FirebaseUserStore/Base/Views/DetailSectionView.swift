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
            VStack {
                ItemsSectionView.createSectionView(section: section)
                    .frame(height: 480)
                    .closeToolbar(onClose)
                    .ignoresSafeArea()

                detailContent(section: section)
            }
            .offset(y: offset)
        }
        .padding(.vertical)
        .cornerRadius(9)
        .edgesIgnoringSafeArea(.horizontal)
        .onChange(of: detailScale) {
            let offset = 2000 - $0 * 2000
            self.offset = -offset
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
