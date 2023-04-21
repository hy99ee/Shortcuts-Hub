import SwiftUI

struct ItemListView: View, Identifiable {
    let id = UUID()
    let item: Item
    
    var body: some View {
        VStack {
            HStack {
                if let iconString = "https://dev1-images.wallpaperscraft.com/image/dynamic/890_360x720.jpg",
                   let iconUrl = URL(string: iconString) {
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
//                    .padding(.bottom, 10)
                    .cornerRadius(9)
                    .padding(4)
                }
//                if item.iconUrl != nil {
//                    imageView
//                        .frame(width: 100, height: 100)
//                        .cornerRadius(15)
//                }

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
                    
                    Divider()
                }
            }
            .padding([.horizontal], 8)

            
        }
//        .padding([.bottom, .leading])
//        .overlay(
//            RoundedRectangle(cornerRadius: 4)
//                .stroke(.secondary, lineWidth: 2)
//        )
        .padding(8)
        
    }

//    @ViewBuilder private var imageView: some View {
//        if image != nil {
//            image!.resizable()
//        } else {
//            ZStack {
//                Rectangle()
//                    .foregroundColor(.secondary.opacity(0.3))
//
//                HDotsProgress()
//            }
//        }
//    }
}
