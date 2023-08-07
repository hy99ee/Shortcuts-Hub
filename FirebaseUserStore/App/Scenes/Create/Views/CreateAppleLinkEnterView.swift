import SwiftUI
import Combine

struct CreateAppleLinkEnterView: View {
    @StateObject var store: CreateStore
    @State private var link = ""
    @State private var height: CGFloat = 0

    @State private var pasteboard: String?

    var body: some View {
        VStack {
            Spacer()

            HStack {
                InputTextFieldView(
                    text: $link,
                    placeholder: "Enter link",
                    errorMessage: bindingMessageForLink,
                    isValid: bindingIsValidForLink,
                    cleanHandler: { store.dispatch(.clickLinkField) },
                    focusHandler: { self.pasteboard = nil }
                )
                .submitLabel(.send)
                .frame(height: height)
                .padding()
            }

            Spacer()

            continueButton
                .modifier(ButtonProgressViewModifier(progressStatus: store.state.buttonProgress, type: .buttonView))
                .padding()
        }
        .background(.opacity(0.001))
        .modifier(OnTapGestureDismissingKeyboard())
        .onAppear {
            pasteboard = UIPasteboard.general.string
        }
    }

    @ViewBuilder var continueButton: some View {
        if let pasteboard, !pasteboard.isEmpty {
            ButtonView(title: "Paste and continue") {
                let string = UIPasteboard.general.string ?? ""
                link = string
                store.dispatch(.linkRequest(string))
            }
        } else {
            let binding = Binding<Bool> { link.isEmpty } set: { _ in }

            ButtonView(title: "Continue", disabled: binding) {
                store.dispatch(.linkRequest(link))
            }
        }
    }

    private var bindingIsValidForLink: Binding<Bool> {
        Binding(
            get: {
                store.state.linkField.isStateValidForField
            }, set: { _ in
                store.dispatch(.clickLinkField)
            }
        )
    }

    private var bindingMessageForLink: Binding<String?> {
        Binding(
            get: {
                switch store.state.linkField {
                case let .unvalidWithMessage(message): return message
                case .unvalid: return "Unvalid shortcuts URL"
                default: return nil
                }
            }, set: { _ in
            }
        )
    }
}
