import Combine
import SwiftUI
import Firebase

let createDispatcher: DispatcherType<CreateAction, CreateMutation, LibraryPackages> = { action, packages in
    switch action {
    case .linkRequest:
        return mutationLinkRequest(packages)

    case let .uploadNewItem(item):
        return mutationItemUpload(item: item, packages)

    case let .showError(error):
        return Just(.setError(error)).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationLinkRequest(_ packages: LibraryPackages) -> AnyPublisher<CreateMutation, Never> {
        Just(.itemUpdate).eraseToAnyPublisher()
    }

    func mutationItemUpload(item: Item, _ packages: LibraryPackages) -> AnyPublisher<CreateMutation, Never> {
        packages.itemsService.uploadNewItem(item)
            .map { _ in CreateMutation.itemUploaded }
            .catch { _ in Just(.setError(.upload)) }
            .eraseToAnyPublisher()
    }

}


var imageLink = "https://www.apple.com/ru/"
