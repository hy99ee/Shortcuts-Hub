import SwiftUI

struct FeedCellView: View, Identifiable {
    let id = UUID()
    let item: Item
    let cellStyle: CollectionRowStyle
    var delete: (() -> ())? = nil

    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.blue)
                Text(item.title)
                    .font(.title2)
            }

            if let imageName = systemImageByItemStatus {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: imageName)
                            .frame(width: 20, height: 20)
//                            .foregroundColor(.random)
                            .padding([.top, .trailing], 5)
                    }
                    Spacer()
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue, lineWidth: 2)
        )
        .frame(height: cellStyle.rowHeight)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12, style: .continuous))
        .contextMenu {
            if let delete {
                Button(role: .destructive) {
                    delete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private var systemImageByItemStatus: String? {
        switch ItemValidateStatus(rawValue: item.validateByAdmin) {
        case .undefined: return "clock.arrow.circlepath"
        case .decline: return "exclamationmark.circle"
        default: return nil
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

