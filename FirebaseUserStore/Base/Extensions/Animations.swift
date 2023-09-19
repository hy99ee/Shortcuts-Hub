import SwiftUI

extension Animation {
    public static var pumping: Animation { .interactiveSpring(response: 0.33, dampingFraction: 0.65, blendDuration: 0.65) }
}
