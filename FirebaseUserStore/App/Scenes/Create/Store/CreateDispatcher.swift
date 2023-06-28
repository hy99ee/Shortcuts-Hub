import Combine
import SwiftUDF
import Firebase

let createDispatcher: DispatcherType<CreateAction, CreateMutation, LibraryPackages> = { action, packages in
    switch action {
    case let .linkRequest(link):
        return mutationRequestItemFromAppleApi(link: link, packages)
            .withStatus(start: .progressButton(status: .start), finish: .progressButton(status: .stop))

    case let .uploadNewItem(item):
        return mutationItemUpload(item: item, packages)

    case .clickLinkField:
        return Just(.linkFieldStatus(.valid)).eraseToAnyPublisher()

    case let .showError(error):
        return Just(.setError(error)).eraseToAnyPublisher()
    }

    // MARK: - Mutations
    func mutationItemUpload(item: Item, _ packages: LibraryPackages) -> AnyPublisher<CreateMutation, Never> {
        packages.itemsService.uploadNewItem(item)
            .handleEvents(
                receiveOutput: { _ in
                    packages.sessionService.firestoreMutation = .add(item: item)
                }
            )
            .map { _ in .itemUploaded }
            .catch { _ in Just(.setError(.upload)) }
            .eraseToAnyPublisher()
    }

    func mutationRequestItemFromAppleApi(link: String, _ packages: LibraryPackages) -> AnyPublisher<CreateMutation, Never> {
        guard verifyUrl(link),
            let userId = link.split(separator: "/").last else {
            return Just(.linkFieldStatus(.unvalid)).eraseToAnyPublisher()
        }

        return Just(String(userId))
            .flatMap {
                packages.itemsService.requestItemFromAppleApi(appleId: $0)
            }
            .map { .setAppleItem($0, linkFromUser: link) }
            .catch { _ in Just(.setError(.upload)) }
            .eraseToAnyPublisher()
    }

    func verifyUrl(_ urlString: String) -> Bool {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }

        return false
    }
}
