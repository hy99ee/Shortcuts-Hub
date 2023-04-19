import Foundation
import Combine
import SwiftUI

let feedFeedDetailSectionSectionDispatcher: DispatcherType<FeedDetailSectionAction, FeedDetailSectionMutation, FeedDetailSectionPackages> = { action, packages in
    switch action {
    case .initDetail:
        return Just(())
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .flatMap { _ in Just(FeedDetailSectionMutation.fetchedSection) }
            .eraseToAnyPublisher()
            .withStatus(start: .progressViewStatus(status: .start), finish: .progressViewStatus(status: .stop))
            .eraseToAnyPublisher()

    case .close:
        return Just(FeedDetailSectionMutation.close).eraseToAnyPublisher()
    }

    //MARK: Mutations

}

