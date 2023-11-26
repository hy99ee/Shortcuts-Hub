import Combine
import SwiftUDF
import SwiftUI

struct FeedDetailSectionState: StateType {
    let idsSection: IdsSection
    var itemsFromSection: [Item] = []

    var viewProgress: ProgressViewStatus = .start
    var processView: ProcessViewStatus = .enable

    static func == (lhs: FeedDetailSectionState, rhs: FeedDetailSectionState) -> Bool {
        lhs.idsSection.id == rhs.idsSection.id
    }

    func reinit() -> Self { self }
}
