import SwiftUI

struct ItemCellView: View, Identifiable {
    let id = UUID()
    let item: Item
    let cellStyle: CollectionRowStyle
    var isFromSelf: Bool = false

    var body: some View {
        ZStack {
            
                if let iconData = item.icon,
                   let imageFromData = UIImage(data: iconData),
                   let rgbaImage = RGBAImage(image: imageFromData),
                   let backgroudColor = makeAverageColorForImage(rgbaImage) {
                    ZStack {
//                        Image(uiImage: rgbaImage.replaceWhitePixelsWithCentralPixel().toUIImage()!)
//                            .resizable()
//                            .scaledToFit()
//                            .clipped()
                        Rectangle()
//                            .fill(Color(uiColor: rgbaImage.replacePixelsWithTransparent().toUIImage()!.averageColor ?? .clear))
                            .fill(
                                
                                LinearGradient(
                                    colors: [
                                        backgroudColor.adjust(brightness: 0.1),
                                        backgroudColor.adjust(saturation: 0.1, brightness: -0.1, opacity: 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(12)
//                            .opacity(0.9)

                        VStack {
                            HStack {
                                Image(uiImage: imageFromData)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()

                                    .cornerRadius(8)
                                    .padding(8)
                                    .shadow(radius: 8)
//                                    .blendMode(.color)
//                                    .blur(radius: 12)
//                                    .cornerRadius(8)
                                
                                
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            
                            Text(item.title)
                                .font(.system(size: 20))
                        }
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.secondary)
                            .opacity(0.6)

                        Text(item.title)
                            .font(.title3)
                    }
                }
                
            

            if isFromSelf, let imageName = systemImageByItemStatus {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: imageName)
                            .frame(width: 20, height: 20)
                            .padding([.top, .trailing], 5)
                    }
                    Spacer()
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.secondary, lineWidth: 2)
        )
        .foregroundColor(.white)
        .frame(height: cellStyle.rowHeight)
        .cornerRadius(12)
    }

    private var systemImageByItemStatus: String? {
        switch ItemValidateStatus(rawValue: item.validateByAdmin) {
        case .undefined: return "clock.arrow.circlepath"
        case .decline: return "exclamationmark.circle"
        default: return nil
        }
    }

    private func makeAverageColorForImage(_ image: RGBAImage) -> Color? {
        if let image = image.replaceWhitePixelsWithCentralPixel().toUIImage(),
           let uiColor = image.averageColor {
            return Color(uiColor: uiColor)
        } else {
            return nil
        }
    }
//
//    private func topColorForImage(_ image: RGBAImage) -> Color {
//        Color(image.pixels[100].toUIColor())
//    }
//
//    private func bottomColorForImage(_ image: RGBAImage) -> Color {
//        Color(image.pixels[image.pixels.count - 100].toUIColor())
//    }
//
//    private func backgroundGradient(for image: RGBAImage) -> [Color] {
//        let avarageColor = makeAverageColorForImage(image)
//        return [
//            avarageColor.adjust(brightness: 0.01),
////            avarageColor.adjust(brightness: ),
//            avarageColor.adjust(saturation: 0.3, brightness: -0.1, opacity: 0.9),
////            avarageColor
//        ]
//    }
}

struct LoaderFeedCellView: View {
    var loaderItem: LoaderItem? = nil
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color(uiColor: .systemBackground))
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.3)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue, lineWidth: 2)
        )
    }
}

