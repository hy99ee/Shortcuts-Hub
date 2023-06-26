import SwiftUI

struct ItemCellView: View, Identifiable {
    let id = UUID()
    let item: Item
    let cellStyle: CollectionRowStyle
    var isFromSelf: Bool = false

    var body: some View {
        ZStack {
                if let iconData = item.icon,
                   let imageFromData = UIImage(data: iconData) {
                    ZStack {
                        Rectangle()
                            .fill(Color(rgb: item.colorValue ?? 0))
                            .cornerRadius(12)

                    VStack {
                        if cellStyle == .row3 {
                            Image(uiImage: imageFromData)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .shadow(radius: 8)
                                .cornerRadius(8)
                                .shadow(radius: 8)
                        } else {
                            HStack {
                                Image(uiImage: imageFromData)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .shadow(radius: 8)
                                    .padding(8)
                                    .shadow(radius: 8)

                                Spacer()
                            }

                            Spacer()

                            Text(item.title)
                                .font(.system(size: 20))
                        }
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
        if let image = image.toUIImage(),
           let uiColor = image.averageColor {
            return Color(uiColor: uiColor)
        } else {
            return nil
        }
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
