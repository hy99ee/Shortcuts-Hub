import SwiftUI

struct CollectionEmptyView: View {
    let message: String
    let status: ProgressViewStatus
    let action: () -> ()

    var body: some View {
        VStack {
            Spacer()

            Image("EmptyIcon")
                .resizable()
                .frame(width: 70, height: 70)
                .modifier(ButtonProgressViewModifier(progressStatus: status, type: .backgroundView))
                .padding()
                .onTapGesture { action() }

            Text(message)
                .font(.system(size: 23, weight: .bold, design: .monospaced))

            Spacer()
        }
    }
}
