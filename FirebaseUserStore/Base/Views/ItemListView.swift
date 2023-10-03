import SwiftUI

struct ItemListView: View, Identifiable {
    let id = UUID()
    let item: Item

    private let iconString = "https://dev1-images.wallpaperscraft.com/image/dynamic/890_360x720.jpg"
    
    var body: some View {
        VStack {
            HStack {
                if let iconUrl = URL(string: iconString) {
                    CacheAsyncImage<Image, Color, Color>(
                        url: iconUrl,
                        content: { image in
                            guard let image = image.image else { return nil }
                            return image.resizable(resizingMode: .stretch)
                        },
                        placeholder: { Color.secondary },
                        errorView: { Color.red }
                    )
                    .frame(width: 80, height: 80)
                    .cornerRadius(9)
                    .padding(4)
                }

                VStack {
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
                    .padding(.vertical, 12)


                }
                if let linkString = item.originalUrl,
                   !linkString.isEmpty,
                   let link = URL(string: linkString) {
//                    HStack(alignment: .center) {
                        CollectionShortcutAddButton(link: link)
//                            .padding()
//                    }

                }

            }
            .padding(.horizontal, 8)
        }
        .padding(8)

        Divider()
            .padding(.horizontal, 8)
        
    }
}
