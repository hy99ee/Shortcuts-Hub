import SwiftUI
import Combine

struct CreateAppleLinkEnterView: View {
    @StateObject var store: CreateStore
    @State private var link = ""
    @State private var height: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()
            Link(destination: URL(string: "https://apps.apple.com/us/app/shortcuts/id915249334")!) {
                Image(systemName: "link.circle.fill")
                    .font(.largeTitle)
            }
            .padding()

            Spacer()

            InputTextFieldView(
                text: $link,
                placeholder: "Enter link",
                errorMessage: .constant("Unvalid shortcuts URL"),
                isValid: .constant(store.state.linkField != .unvalid),
                cleanHandler: { store.dispatch(.clickLinkField) },
                focusHandler: { store.dispatch(.clickLinkField) }
            )
                .frame(height: height)
                .padding()
                .onSubmit {
                    store.dispatch(.linkRequest(link))
                }
                .submitLabel(.send)

            Spacer()

            ButtonView(title: "Next") {
                store.dispatch(.linkRequest(link))
            }
            .modifier(DismissingKeyboard())
            .modifier(ButtonProgressViewModifier(progressStatus: store.state.buttonProgress, type: .buttonView))
            .padding()
        }
        .background(.opacity(0.001))
        .modifier(DismissingKeyboard())
    }
}
