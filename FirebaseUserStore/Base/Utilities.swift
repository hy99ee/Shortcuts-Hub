import SwiftUI

class Utilities {
    static let shared = Utilities()
    @AppStorage("selectedAppearance") private var selectedAppearance: UIUserInterfaceStyle = .dark

    func overrideDisplayMode() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.keyWindow?.overrideUserInterfaceStyle = selectedAppearance
        }
    }

    var safeAreaInsets: UIEdgeInsets? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets
        } else {
            return nil
        }
    }

    var sceneSize: CGRect? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.bounds
        } else {
            return nil
        }
    }
}
