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
                   let rgbaImage = RGBAImage(image: imageFromData) {
                    ZStack {
                        Rectangle()
                            .fill(Color(uiColor: rgbaImage.replacePixelsWithTransparent().toUIImage()!.averageColor ?? .clear))
                            .background(
                                LinearGradient(colors: [.white, .clear],
                                                       startPoint: .top,
                                                       endPoint: .center)
                                )
                            .cornerRadius(12)
                            .opacity(0.9)

                        VStack {
                            HStack {
                                Image(uiImage: imageFromData)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(8)
                                    .padding(6)

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
    }

    private var systemImageByItemStatus: String? {
        switch ItemValidateStatus(rawValue: item.validateByAdmin) {
        case .undefined: return "clock.arrow.circlepath"
        case .decline: return "exclamationmark.circle"
        default: return nil
        }
    }

    private func getColor(at point: CGPoint) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.translateBy(x: -point.x, y: -point.y)
        let color = UIColor(red:   CGFloat(pixel[0]) / 255.0,
                            green: CGFloat(pixel[1]) / 255.0,
                            blue:  CGFloat(pixel[2]) / 255.0,
                            alpha: CGFloat(pixel[3]) / 255.0)

        pixel.deallocate()
        return color
    }
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

