import SwiftUI

protocol ProcessViewProviderType: ObservableObject {
    var processViewStatus: Bool { get set }
}

struct ProcessViewModifier<ProcessProvider: ProcessViewProviderType>: ViewModifier {
    @ObservedObject var provider: ProcessProvider

    func body(content: Content) -> some View {
        content
            .disabled(provider.processViewStatus)
        
    }
}
