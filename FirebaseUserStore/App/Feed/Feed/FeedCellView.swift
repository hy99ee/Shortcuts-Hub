import SwiftUI

struct FeedCellView: View {
    let title: String
    var body: some View {
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
        .frame(height: 140)
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
        .frame(height: 140)
    }
}

