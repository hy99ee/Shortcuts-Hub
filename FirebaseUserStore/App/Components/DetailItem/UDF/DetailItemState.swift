import SwiftUDF

struct DetailItemState: StateType {
    var item: Item

    var viewProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable

    static func == (lhs: DetailItemState, rhs: DetailItemState) -> Bool {
        lhs.item.id == rhs.item.id
    }

    func reinit() -> Self { self }
}
