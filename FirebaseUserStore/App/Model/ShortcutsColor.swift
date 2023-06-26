import SwiftUI

enum AppleShortcutsColor: Int {
    case red = 4282601983
    case orange = 4251333119
    case tangerine = 4271458815
    case yellow = 4274264319
    case green = 4292093695
    case teal = 431817727
    case lightblue = 1440408063
    case blue = 463140863
    case navy = 946986751
    case grape = 2071128575
    case purple = 3679049983
    case pink = 3980825855
    case grayblue = 255
    case graygreen = 3031607807
    case graybrown = 2846468607

}

enum ShortcutsColor: UInt64 {
    case red = 4282601983
    case darkOrange = 4251333119
    case orange = 4271458815
    case yellow = 4274264319
    case green = 4292093695
    case teal = 431817727
    case lightBlue = 1440408063
    case blue = 463140863
    case darkBlue = 946986751
    case violet = 2071128575
    case purple = 3679049983
    case darkGray = 255
    case pink = 3980825855
    case taupe = 3031607807
    case gray = 2846468607

    var color: Color {
        switch self {
        case .red:
            return Color(red: 226 / 255.0, green: 111 / 255.0, blue: 111 / 255.0)
        case .darkOrange:
            return Color(red: 241 / 255.0, green: 139 / 255.0, blue: 112 / 255.0)
        case .orange:
            return Color(red: 236, green: 170, blue: 97)
        case .yellow:
            return Color(red: 241, green: 139, blue: 112)
        case .green:
            return Color(red: 241, green: 139, blue: 112)
        case .teal:
            return Color(red: 241, green: 139, blue: 112)
        case .lightBlue:
            return Color(red: 241, green: 139, blue: 112)
        case .blue:
            return Color(red: 241, green: 139, blue: 112)
        case .darkBlue:
            return Color(red: 241, green: 139, blue: 112)
        case .violet:
            return Color(red: 241, green: 139, blue: 112)
        case .purple:
            return Color(red: 241, green: 139, blue: 112)
        case .darkGray:
            return Color(red: 241, green: 139, blue: 112)
        case .pink:
            return Color(red: 241, green: 139, blue: 112)
        case .taupe:
            return Color(red: 241, green: 139, blue: 112)
        case .gray:
            return Color(red: 241, green: 139, blue: 112)
        }
    }

    var colorValue: Int {
        switch self {
        case .red: return 0xFF4351FF
        case .darkOrange: return 0xFD6631FF
        case .orange: return 0xFE9949FF
        case .yellow: return 0xEC418FF
        case .green: return 0xFFD426FF
        case .teal: return 0x19BD03FF
        case .lightBlue: return 0x55DAE1FF
        case .blue: return 0x1B9AF7FF
        case .darkBlue: return 0x3871DEFF
        case .violet: return 0x7B72E9FF
        case .purple: return 0xDB49D8FF
        case .darkGray: return 0x000000FF
        case .pink: return 0xED4694FF
        case .taupe: return 0xB4B2A9FF
        case .gray: return 0xA9A9A9FF
        }
    }
}
