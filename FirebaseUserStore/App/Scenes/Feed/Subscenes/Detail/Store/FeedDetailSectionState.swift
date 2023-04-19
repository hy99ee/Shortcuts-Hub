import SwiftUI
import Combine

struct FeedDetailSectionState: StateType {    
    init(section: IdsSection) {
        idsSection = section
    }
    
    let idsSection: IdsSection
    var itemsSection: ItemsSection?

    var viewProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable

    static func == (lhs: FeedDetailSectionState, rhs: FeedDetailSectionState) -> Bool {
        lhs.idsSection.id == rhs.idsSection.id
    }

    func reinit() -> Self { self }
}
