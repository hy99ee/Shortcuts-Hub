import Foundation

extension Array {
    var zipped: [(Element, Element?)] {
        let _self: [Element?] = self
        let shifted = _self.dropFirst() + [nil]
        return Swift.zip(self, shifted).map { ($0, $1) }
    }
}
