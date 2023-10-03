import SwiftUI

struct DetailShortcutAddButton: ShortcutAddButtonType {
    let link: URL

    var body: some View {
        Link(destination: link) {
            HStack {
                Spacer()
                Image(systemName: "plus.circle.fill")

                Text("Add Shortcut")
                        .bold()

                Spacer()
            }

            .padding()
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)
        }
    }
}

struct DetailShortcutAddButton_Preview: PreviewProvider {
    static var previews: some View {
        DetailShortcutAddButton(link: URL(string: "www.ru.com")!)
    }
}
