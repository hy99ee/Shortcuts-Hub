import SwiftUI

struct ItemDetailView: View {
    @StateObject var store: DetailItemStore

    @State private var image: Image?
    @State private var savedImageSystemName: String = Self.imageSystemNameByStoreOperation()

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
        .onReceive(store.$state) {
            savedImageSystemName = Self.imageSystemNameByIsSaved($0.item.isSaved)
        }
        .onAppear {
            savedImageSystemName = Self.imageSystemNameByIsSaved(store.state.item.isSaved)

            if let iconData = store.state.item.icon, let image = UIImage(data: iconData) {
                self.image = Image(uiImage: image)
            }
        }
        .toolbar {
            if store.state.item.userId != store.packages.sessionService.userDetails.auth?.id {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        store.dispatch(store.state.item.isSaved ? .removeFromSaved : .addToSaved)
                    }, label: {
                        Image(systemName: savedImageSystemName)
                    })
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

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }

            if let image = UIImage(data: data) {
                self.image = Image(uiImage: image)
            }
        }
    }

    static private func imageSystemNameByIsSaved(_ isSaved: Bool) -> String {
        Self.imageSystemNameByStoreOperation(isSaved ? .saved : .unsaved)
    }
    
    static private func imageSystemNameByStoreOperation(_ operation: DetailItemStore.Operation = .unsaved) -> String {
        switch operation {
        case .saved:
            return "heart.fill"
        case .unsaved:
            return "heart"
        }
    }
}
