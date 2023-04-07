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

struct OnCloseViewModifier: ViewModifier {
    let onClose: () -> ()
    
    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            onClose()
                        }
                        .padding()
                }
                Spacer()
            }
        }
    }
}

struct CloseToolbarViewModifier: ViewModifier {
    let onClose: () -> ()
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        onClose()
                    }
                    
            }
    }
}

enum CloseButtonSite {
    case tollbar
    case view
}

extension View {
    @ViewBuilder func closeToolbar(_ onClose: @escaping () -> ()) -> some View {
        self.modifier(CloseToolbarViewModifier(onClose: onClose))
    }

    @ViewBuilder func applyClose(_ onClose: @escaping () -> ()) -> some View {
        self.modifier(OnCloseViewModifier(onClose: onClose))
    }

    @ViewBuilder func applyClose(_ style: CloseButtonSite = .tollbar) -> some View {
        switch style {
        case .tollbar:
            self.modifier(NavigationCloseToolbarViewModifier())
        case .view:
            self.modifier(NavigationCloseViewModifier())
        }
    }

    @ViewBuilder func applyClose<T>(closeBinding: Binding<T?>, _ style: CloseButtonSite = .tollbar) -> some View {
        switch style {
        case .tollbar:
            self.modifier(NavigationCloseToolbarViewModifier())
        case .view:
            let _closeBinding = Binding<Bool>(
                get: { closeBinding.wrappedValue != nil },
                set: { _ in closeBinding.wrappedValue = nil }
            )
            self.modifier(NavigationBindingCloseViewModifier(onClose: _closeBinding))
        }
    }
}
