import SwiftUI
import Combine

struct CreateAppleLinkEnterView: View {
    let store: CreateStore
    @State private var link = ""
    @State private var height: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()
            InputTextFieldView(text: $link, placeholder: "Enter link", withCleanButton: true)
                .frame(height: height)
                .padding()
                .onSubmit {
                    store.dispatch(.linkRequest(link))
                }
                .submitLabel(.send)
            Spacer()
        }
        .background(.opacity(0.01))
        .modifier(DismissingKeyboard())
    }
}
