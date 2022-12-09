import SwiftUI

struct FeedCellView: View {
    let title: String
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12).foregroundColor(.random)
            Text(title)
                .font(.title2)
        }
        
    }
}

struct LoaderFeedCellView: View {
    let title: String
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12).foregroundColor(.random)
                ProgressView()
            }
            Text(title)
                .font(.title2)
        }
        
    }
}

