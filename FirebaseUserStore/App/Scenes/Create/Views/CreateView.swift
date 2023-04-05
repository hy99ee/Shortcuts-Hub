import SwiftUI
import Combine
import FirebaseAuth

struct CreateView: View {
    let store: CreateStore
    let appleItem: AppleApiItem
    let originalLink: String

    @State private var titleField = ""
    @State private var descriptionField = ""
    @State private var image: Image?

    var userId: String? { Auth.auth().currentUser?.uid }

    var body: some View {
        VStack {
            TextField("Enter title", text: $titleField)
                .bold()

            imageView
                .frame(width: 100, height: 100)
                .cornerRadius(15)

            TextField("Enter description", text: $descriptionField)
            .padding()

            ButtonView(title: "Create") {
                store.dispatch(.uploadNewItem(itemBySelf))
            }
            .padding()
        }
        .onAppear {
            titleField = appleItem.fields.name.value
            
            if let stringUrl = appleItem.fields.icon.value.downloadURL
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: stringUrl) {
                downloadImage(from: url)
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

    var itemBySelf: Item {
        Item(
            id: UUID(),
            userId: userId!,
            title: titleField,
            description: descriptionField,
            iconUrl: appleItem.fields.icon.value.downloadURL,
            originalUrl: originalLink,
            createdAt: Date()
        )
    }
}
