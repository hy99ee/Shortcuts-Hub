import SwiftUI

struct NavigationCloseToolbarViewModifier: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
    }
}

struct NavigationCloseViewModifier: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }.padding()
            Spacer()
            VStack {
                Spacer()
                content
                Spacer()
            }
        }
    }
}

struct NavigationBindingCloseViewModifier: ViewModifier {
    @Binding var onClose: Bool
    
    func body(content: Content) -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    onClose = true
                }, label: {
                    Image(systemName: "xmark")
                })
            }.padding()
            Spacer()
            VStack {
                Spacer()
                content
                Spacer()
            }
        }
    }
}

enum CloseButtonSite {
    case tollbar
    case view
}

extension View {
    @ViewBuilder func applyClose(_ style: CloseButtonSite = .tollbar) -> some View {
        switch style {
        case .tollbar:
            self.modifier(NavigationCloseToolbarViewModifier())
        case .view:
            self.modifier(NavigationCloseViewModifier())
        }
    }

    @ViewBuilder func applyClose<T>(onClose: Binding<T?>, _ style: CloseButtonSite = .tollbar) -> some View {
        switch style {
        case .tollbar:
            self.modifier(NavigationCloseToolbarViewModifier())
        case .view:
            let closeBinding = Binding<Bool>(
                get: { onClose.wrappedValue != nil },
                set: { _ in onClose.wrappedValue = nil }
            )
            self.modifier(NavigationBindingCloseViewModifier(onClose: closeBinding))
        }
    }
}
