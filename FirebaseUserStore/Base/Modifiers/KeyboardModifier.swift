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
