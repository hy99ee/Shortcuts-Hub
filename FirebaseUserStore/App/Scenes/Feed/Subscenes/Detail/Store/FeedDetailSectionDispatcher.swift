import Foundation
import Combine
import SwiftUI

let feedFeedDetailSectionSectionDispatcher: DispatcherType<FeedDetailSectionAction, FeedDetailSectionMutation, FeedDetailSectionPackages> = { action, packages in
    switch action {
    case .initDetail:
        return Just(FeedDetailSectionMutation.close).eraseToAnyPublisher()

    case let .updateWithSection(section):
        return mutationFetchSections(section: section, packages: packages)
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
            .withStatus(start: .progressViewStatus(status: .start), finish: .progressViewStatus(status: .stop))
            .eraseToAnyPublisher()

    case .close:
        return Just(FeedDetailSectionMutation.close).eraseToAnyPublisher()
    }

    // MARK: - Mutations
    func mutationFetchSections(section: IdsSection, packages: FeedDetailSectionPackages) -> AnyPublisher<FeedDetailSectionMutation, Never> {
        let fetchDocs = packages.feedDetailSectionService.fetchQuery(from: section)

        let fetchFromDocs = fetchDocs
            .map { $0.query }
            .flatMap { packages.feedDetailSectionService.fetchItemsFromQuery($0) }
        
        return
            fetchFromDocs
                .map { .fetchedSection($0) }
                .catch { _ in Just(.close) }
                .eraseToAnyPublisher()
        
    }
    
}

