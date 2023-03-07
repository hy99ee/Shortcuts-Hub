import SwiftUI
import Combine

struct CreateView: View {
    let store: CreateStore
    @State private var titleField = ""
    @State private var descriptionField = ""
    @Binding var id: UUID?
    
    var body: some View {
        VStack {
            TextField("Enter title", text: $titleField).padding()
            TextField("Enter description", text: $descriptionField).padding()
            ImageView(systemName: "xmark") {
                id = UUID()
                store.dispatch(.uploadNewItem(
                    Item(
                        id: id!,
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
