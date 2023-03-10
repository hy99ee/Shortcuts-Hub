import SwiftUI

struct AppearanceButton: View {
    @AppStorage("selectedAppearance") var selectedAppearance: UIUserInterfaceStyle = .dark
    var utilities = Utilities.shared

    var body: some View {
        Button(action: {
            selectedAppearance = selectedAppearance.next
        }) {
            Image(systemName: selectedAppearance.systemIcon)
        }
        .onChange(of: selectedAppearance, perform: { value in
            withAnimation {
                utilities.overrideDisplayMode()
            }
         })
    }
}

extension UIUserInterfaceStyle {
    var next: Self {
        switch self {
        case .unspecified:
            return .dark
        case .light:
            return .dark
        case .dark:
            return .light
        @unknown default:
            return .light
        }
    }
    
    var systemIcon: String {
        switch self {
        case .unspecified:
            return "cloud"
        case .light:
            return "moon"
        case .dark:
            return "sun.max"
        @unknown default:
            return ""
        }
    }
}
