import Foundation

enum CollectionRowStyle: CaseIterable {
    case row2
    case row3

    var systemImage: String {
        switch self {
        case .row2: return "square.split.2x2"
        case .row3: return "rectangle.split.3x3"
        }
    }

    var systemImageSize: CGFloat {
        switch self {
        case .row2: return 17
        case .row3: return 15
        }
    }

    var rowCount: Int {
        switch self {
        case .row2: return 2
        case .row3: return 3
        }
    }

    var rowHeight: CGFloat {
        switch self {
        case .row2: return 120
        case .row3: return 100
        }
    }
}

extension CaseIterable where Self: Equatable, AllCases: BidirectionalCollection {
    func previous() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let previous = all.index(before: idx)
        return all[previous < all.startIndex ? all.index(before: all.endIndex) : previous]
    }

    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
