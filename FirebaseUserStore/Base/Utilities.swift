import SwiftUI

class Utilities {
    static let shared = Utilities()
    @AppStorage("selectedAppearance") var selectedAppearance: UIUserInterfaceStyle = .dark

    func overrideDisplayMode() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.keyWindow?.overrideUserInterfaceStyle = selectedAppearance
        }
    }
}
