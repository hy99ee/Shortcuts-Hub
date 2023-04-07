import Combine
import SwiftUI

struct DisabledTimerViewModifier: ViewModifier {
    @State private var disable = true

    private var cancelable: AnyCancellable
    private var emitter = PassthroughSubject<Void, Never>()

    init(deadline: CGFloat) {
        cancelable = Just(())
            .delay(for: .seconds(deadline), scheduler: DispatchQueue.main)
            .subscribe(emitter)
            
    }

    func body(content: Content) -> some View {
        content
            .disabled(disable)
            .onReceive(emitter) { _ in
                disable = false
            }
    }
}

extension View {
    @ViewBuilder func animationAdapted(animationDuration: CGFloat) -> some View {
        self.modifier(DisabledTimerViewModifier(deadline: animationDuration))
    }
}
