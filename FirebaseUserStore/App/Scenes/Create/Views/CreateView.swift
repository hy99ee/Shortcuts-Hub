import SwiftUI
import Combine

struct CreateView: View {
    let store: CreateStore
    let initialItem: AppleApiItem
    @Binding var id: UUID?

    @State private var titleField = ""
    @State private var descriptionField = ""
    @State private var image: Image?
    
    
    
    var body: some View {
        VStack {
            Text(initialItem.fields.name.value).bold()
            Text(initialItem.created.deviceID)
            Text(initialItem.fields.iconColor.type)
            imageView
                .frame(width: 100, height: 100)
                .cornerRadius(15)

        }.onAppear {
            if let stringUrl = initialItem.fields.icon.value.downloadURL
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
                    .foregroundColor(.secondary)

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
}
