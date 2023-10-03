import SwiftUI

struct CollectionShortcutAddButton: ShortcutAddButtonType {
    let link: URL

    var body: some View {
        Link(destination: link) {
            Text("Get")
                .bold()
            .padding(5)
            .frame(width: 60)
            .foregroundColor(.blue)
            .background(Color(UIColor.quaternaryLabel))
            .cornerRadius(15)

        }

    }
}

struct CollectionShortcutAddButton_Preview: PreviewProvider {
    static var previews: some View {
        CollectionShortcutAddButton(link: URL(string: "www.ru.com")!)
    }
}
