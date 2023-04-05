import Foundation

enum ProcessViewStatus {
    case enable
    case disable

    static func define(with progresses: ProgressViewStatus...) -> Self {
        progresses.filter { $0 == .start }.isEmpty ? .enable : .disable
    }

    var isDisable: Bool { self == .disable }
}
