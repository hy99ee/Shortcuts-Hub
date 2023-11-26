import SwiftUI

struct ItemListView: View, Identifiable {
    let id = UUID()
    let item: Item

    @State private var image: Image?

    var body: some View {
        VStack {
            HStack {
                imageView
                    .frame(width: 50, height: 50)
                    .cornerRadius(9)

                VStack {
                    HStack {
                        VStack {
                            Spacer()

                            HStack {
                                Text(item.title)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                Spacer()
                            }

                            HStack {
                                Text(item.description)
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }

                            Spacer()
                        }
                        .padding(.vertical, 5)

                        if let linkString = item.originalUrl,
                           !linkString.isEmpty,
                           let link = URL(string: linkString) {
                            CollectionShortcutAddButton(link: link)
                        }
                    }

                    Divider()
                }




            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 8)
        .onAppear {
            if let iconData = item.icon,
               let image = UIImage(data: iconData) {
                self.image = Image(uiImage: image)
            }
        }
    }

    @ViewBuilder private var imageView: some View {
        if image != nil {
            image!.resizable()
        } else {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(UIColor.placeholderText.withAlphaComponent(0.15)))
            }
        }
    }
}

struct ItemListView_Preview: PreviewProvider {
    @Namespace static var open
    private static var store = _FeedPackages().makeFeedSectionDetailStore(IdsSection.mockSections.first!)

    static var previews: some View {
        ItemListView(item: Item.mockItems.randomElement()!)
    }
}
