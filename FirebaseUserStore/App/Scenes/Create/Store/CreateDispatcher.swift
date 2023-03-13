import Combine
import SwiftUI
import Firebase

let createDispatcher: DispatcherType<CreateAction, CreateMutation, LibraryPackages> = { action, packages in
    switch action {
    case let .linkRequest(link):
        return mutationRequestItemFromAppleApi(link: link, packages)

    case let .uploadNewItem(item):
        return mutationItemUpload(item: item, packages)

    case let .showError(error):
        return Just(.setError(error)).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationItemUpload(item: Item, _ packages: LibraryPackages) -> AnyPublisher<CreateMutation, Never> {
        packages.itemsService.uploadNewItem(item)
            .map { _ in CreateMutation.itemUploaded }
            .catch { _ in Just(.setError(.upload)) }
            .eraseToAnyPublisher()
    }

    func mutationRequestItemFromAppleApi(link: String, _ packages: LibraryPackages) -> AnyPublisher<CreateMutation, Never> {
        Just(link)
            .compactMap {
                guard let userId = $0.split(separator: "/").last else {
                    return nil
                }
                return String(userId)
            }
            .flatMap {
                packages.itemsService.requestItemFromAppleApi(appleId: $0)
            }
            .map { .setAppleItem($0) }
            .catch { _ in Just(.setError(.upload)) }
            .eraseToAnyPublisher()
    }
}


var imageLink = "https://www.apple.com/ru/"
