import SwiftUI

struct CollectionErrorView: View {
    let message: String
    let status: ProgressViewStatus
    let action: () -> ()

    @State private var errorLibraryDelay = false

    var body: some View {
        VStack {
            Spacer()

            Image("EmptyIcon")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(UIColor.label))
                .frame(width: 70, height: 70)
                .scaleEffect(errorLibraryDelay ? 0.9 : 1)
                .modifier(ButtonProgressViewModifier(progressStatus: status, type: .backgroundView))
                .disabled(errorLibraryDelay)
                .padding()
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.25)) {
                        errorLibraryDelay = true
                        withAnimation(.easeIn(duration: 0.25).delay(0.25)) {
                            errorLibraryDelay = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                Task { action() }
                            }
                        }
                    }
                }


            Text(message)
                .font(.system(size: 23, weight: .bold, design: .monospaced))
                .opacity(status == .start ? 0 : 1)

            Spacer()
        }
    }
}
