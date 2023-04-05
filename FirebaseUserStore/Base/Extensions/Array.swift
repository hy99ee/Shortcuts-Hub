import Foundation

extension Array {
    var zipped: [(Element, Element?)] {
        let _self: [Element?] = self
        let shifted = _self.dropFirst() + [nil]
        return Swift.zip(self, shifted).map { ($0, $1) }
    }

    func at(_ index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element == Item {
    var itemsByModified: [Element] {
        self.sorted {
            $0.modifiedAt ?? $0.createdAt > $1.modifiedAt ?? $1.createdAt
        }
    }
}
