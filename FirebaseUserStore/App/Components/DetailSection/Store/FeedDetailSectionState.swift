import Combine
import SwiftUDF
import SwiftUI

struct FeedDetailSectionState: StateType {    
    init(section: IdsSection) {
        idsSection = section
    }
    
    let idsSection: IdsSection
    var itemsFromSection: [Item] = []

    var viewProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable

    static func == (lhs: FeedDetailSectionState, rhs: FeedDetailSectionState) -> Bool {
        lhs.idsSection.id == rhs.idsSection.id
    }

    func reinit() -> Self { self }
}
