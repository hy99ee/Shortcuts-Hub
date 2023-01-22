import SwiftUI
import Combine

extension Publishers {
    static var keyboardVisible: AnyPublisher<Bool, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { _ in true }

        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in false }

        return Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(keyboardVisible ? 0 : 1)
            .onReceive(Publishers.keyboardVisible) { visible in
                withAnimation {
                    self.keyboardVisible = visible
                }
            }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}
