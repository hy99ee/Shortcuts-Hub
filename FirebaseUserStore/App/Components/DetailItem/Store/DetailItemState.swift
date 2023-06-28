import SwiftUDF

struct DetailItemState: StateType {
    var item: Item

    var viewProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable

//    init(item: Item) {
//        self.item = item
//    }

    static func == (lhs: DetailItemState, rhs: DetailItemState) -> Bool {
        lhs.item.id == rhs.item.id
    }

    func reinit() -> Self { self }
}
