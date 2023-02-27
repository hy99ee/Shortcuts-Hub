import SwiftUI
import Combine

struct CreateView: View {
    @StateObject var store: CreateStore
    @State private var titleField = ""
    @State private var descriptionField = ""
    
    var body: some View {
        VStack {
            TextField("Enter title", text: $titleField).padding()
            TextField("Enter description", text: $descriptionField).padding()
            ImageView(systemName: "xmark") {
                store.dispatch(.uploadNewItem(
                    Item(
                        id: UUID(),
                        userId: "",
                        title: titleField,
                        iconUrl: URL(string: imageLink)!,
                        description: descriptionField,
                        createdAt: Date()
                    )
                ))
            }
        }
    }
}
