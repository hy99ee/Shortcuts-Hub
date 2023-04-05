import SwiftUI

protocol ProcessViewProviderType {
    var processViewStatus: ProcessViewStatus { get set }
}

struct ProcessViewModifier: ViewModifier {
    var process: ProcessViewStatus

    func body(content: Content) -> some View {
        content
            .disabled(process.isDisable)
        
    }
}
