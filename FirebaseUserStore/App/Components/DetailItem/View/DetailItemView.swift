import SwiftUI

struct ItemDetailView: View {
    @StateObject var store: DetailItemStore

    @State private var image: Image?

    var body: some View {
        ScrollView(showsIndicators: false) {
            Text(store.state.item.title).padding()
            Text(store.state.item.description).padding()

            if let link = store.state.item.originalUrl, !link.isEmpty {
                Link(destination: URL(string: link)!) {
                    Image(systemName: "link.circle.fill")
                        .font(.largeTitle)
                }
                .padding()
            }

            if store.state.item.icon != nil {
                imageView
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)
            }
        }
        .onAppear {
            if let iconData = store.state.item.icon, let image = UIImage(data: iconData) {
                self.image = Image(uiImage: image)
            }
        }
        .toolbar {
            if store.state.item.userId != store.packages.sessionService.userDetails.auth?.id {
                ToolbarItem(placement: .navigationBarTrailing) {
                    togleFavoritesButton
                        .modifier(ButtonClearProgressViewModifier(progressStatus: store.state.viewProgress))
                }
            }
        }
    }
    
    
    @ViewBuilder private var imageView: some View {
        if image != nil {
            image!.resizable()
        } else {
            ZStack {
                Rectangle()
                    .foregroundColor(.secondary.opacity(0.3))

                HDotsProgress()
            }
        }
    }

    private var togleFavoritesButton: Button<Image> {
        Button(action: {
            store.dispatch(store.state.item.isSaved ? .removeFromSaved : .addToSaved)
        }, label: {
            Image(systemName: store.state.item.isSaved ? "heart.fill" : "heart")
        })
    }
}
