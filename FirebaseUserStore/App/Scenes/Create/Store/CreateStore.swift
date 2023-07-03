import SwiftUDF
import Combine

typealias CreateStore = StateStore<CreateState, CreateAction, CreateMutation, LibraryPackages, CreateLink>

extension CreateStore {
    static let middlewareCheckInputFormat: Middleware = { state, action, packages in
        if case let .linkRequest(link) = action {
            if link.isEmpty {
                return Fail(
                    error: MiddlewareRedispatch.redispatch(
                        actions: [.showError(.emptyLink)]
                    )
                ).eraseToAnyPublisher()
            } else if !verifyUrl(link) {
                return Fail(
                    error: MiddlewareRedispatch.redispatch(
                        actions: [.showError(.link)]
                    )
                ).eraseToAnyPublisher()
            }
        }

        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()

        func verifyUrl(_ urlString: String) -> Bool {
            urlString.contains("https://www.icloud.com/shortcuts/")
        }
    }

    static let middlewareHideKeyboard: Middleware = { state, action, packages in
        if case let .linkRequest(link) = action {
            hideKeyboard()
        }

        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }


}
