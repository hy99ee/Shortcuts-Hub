import Combine
import SwiftUDF
import SwiftUI

let feedFeedDetailSectionSectionDispatcher: DispatcherType<FeedDetailSectionAction, FeedDetailSectionMutation, FeedDetailSectionPackages> = { action, packages in
    switch action {
    case .initDetail:
        return Just(.close).eraseToAnyPublisher()

    case let .updateFeedWithSection(section):
        return mutationFetchSections(section: section, packages)
            .eraseToAnyPublisher()
            .withStatus(start: .progressViewStatus(status: .start), finish: .progressViewStatus(status: .stop))
            .eraseToAnyPublisher()

    case let .replaceItem(item, index):
        return Just(.replaceItemInSection(item, by: index)).eraseToAnyPublisher()

    case let .open(item):
        return Just(.openItemFromSection(item)).eraseToAnyPublisher()

    case .close:
        return Just(.close).eraseToAnyPublisher()
    }

    // MARK: - Mutations
    func mutationFetchSections(section: IdsSection, _ packages: FeedDetailSectionPackages) -> AnyPublisher<FeedDetailSectionMutation, Never> {
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


let mockFeedFeedDetailSectionSectionDispatcher: DispatcherType<FeedDetailSectionAction, FeedDetailSectionMutation, FeedDetailSectionPackages> = { action, packages in
    switch action {
    case .initDetail:
        return Just(.fetchedSection([Item.mockItems.first!, Item.mockItems.last!])).eraseToAnyPublisher()

    case let .updateFeedWithSection(section):
        return Just(.fetchedSection([Item.mockItems.first!, Item.mockItems.last!]))
            .merge(with: Just(.progressViewStatus(status: .stop)))
            .eraseToAnyPublisher()


    case let .replaceItem(item, index):
        return Just(.replaceItemInSection(item, by: index)).eraseToAnyPublisher()

    case let .open(item):
        return Just(.openItemFromSection(item)).eraseToAnyPublisher()

    case .close:
        return Just(.close).eraseToAnyPublisher()
    }
}
