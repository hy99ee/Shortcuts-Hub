import SwiftUI
import Combine
import FirebaseAuth

struct CreateView: View {
    let store: CreateStore
    let appleItem: AppleApiItem
    let originalLink: String

    @State private var titleField = ""
    @State private var descriptionField = ""
    @State private var image: UIImage?

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
                guard image != nil else { return }
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
        if let uiImage = self.image {
            Image(uiImage: uiImage).resizable()
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

            self.image = UIImage(data: data)
        }
    }

    var itemBySelf: Item {
        Item(
            id: UUID(),
            userId: userId!,
            title: titleField,
            description: descriptionField,
            colorValue: UIImage(data: image?.pngData() ?? Data())?.averageColor?.rgbValue() ?? 0,
            icon: image?.pngData(),
            originalUrl: originalLink,
            createdAt: Date()
        )
    }
}
