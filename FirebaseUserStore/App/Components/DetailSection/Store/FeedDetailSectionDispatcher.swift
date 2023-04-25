import Foundation
import Combine
import SwiftUI

let feedFeedDetailSectionSectionDispatcher: DispatcherType<FeedDetailSectionAction, FeedDetailSectionMutation, FeedDetailSectionPackages> = { action, packages in
    switch action {
    case .initDetail:
        return Just(FeedDetailSectionMutation.close).eraseToAnyPublisher()

    case let .updateFeedWithSection(section):
        return mutationFetchSections(section: section, packages)
            .eraseToAnyPublisher()
            .withStatus(start: .progressViewStatus(status: .start), finish: .progressViewStatus(status: .stop))
            .eraseToAnyPublisher()

    case let .open(item):
        return Just(.openItemFromSection(item)).eraseToAnyPublisher()

    case let .addToSaved(item):
        return mutationItemAddToSaved(item: item, packages).eraseToAnyPublisher()

    case let .removeFromSaved(item):
        return mutationItemRemoveFromSaved(item: item, packages).eraseToAnyPublisher()

    case .close:
        return Just(FeedDetailSectionMutation.close).eraseToAnyPublisher()
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

    func mutationItemAddToSaved(item: Item, _ packages: FeedDetailSectionPackages) -> AnyPublisher<FeedDetailSectionMutation, Never> {
        packages.sessionService.updateDatabaseUser(with: .add(item: item))
            .map { _ in .itemSaved(item) }
            .catch { _ in Just(.close) }
            .eraseToAnyPublisher()
    }
    
    func mutationItemRemoveFromSaved(item: Item, _ packages: FeedDetailSectionPackages) -> AnyPublisher<FeedDetailSectionMutation, Never> {
        packages.sessionService.updateDatabaseUser(with: .remove(item: item))
            .map { _ in .itemUnsaved(item) }
            .catch { _ in Just(.close) }
            .eraseToAnyPublisher()
    }
}

