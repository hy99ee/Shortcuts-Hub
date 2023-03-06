import SwiftUI

struct FeedCellView: View {
    let title: String
    let cellStyle: CollectionRowStyle
    var delete: (() -> ())? = nil

    var body: some View {
        if cellStyle == .row1 {
            horizontalCell
        } else {
            verticalCell
        }
    }

    private var verticalCell: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.blue)
            Text(title)
                .font(.title2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue, lineWidth: 2)
        )
        .frame(height: cellStyle.rowHeight)
//        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12, style: .continuous))
//        .contextMenu {
//            if let delete {
//                Button(role: .destructive) {
//                    delete()
//                } label: {
//                    Label("Delete", systemImage: "trash")
//                }
//            }
//        }
    }

    private var horizontalCell: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.blue)
            Text(title)
                .font(.title2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue, lineWidth: 2)
        )
    }
}

struct LoaderFeedCellView: View {
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

