import Foundation
import Combine
import SwiftUI

let feedFeedDetailSectionSectionDispatcher: DispatcherType<FeedDetailSectionAction, FeedDetailSectionMutation, FeedDetailSectionPackages> = { action, packages in
    switch action {
    case .initDetail:
        return Just(FeedDetailSectionMutation.close).eraseToAnyPublisher()

    case .close:
        return Just(FeedDetailSectionMutation.close).eraseToAnyPublisher()
    }

    //MARK: Mutations

}

