import Combine
import SwiftUI

let createReducer: ReducerType<CreateState, CreateMutation, CreateLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .setAppleItem(item, linkFromUser):
        return Just(.coordinate(destination: .createFromAppleItem(item, linkFromUser: linkFromUser))).eraseToAnyPublisher()

    case .itemUploaded:
        return Just(.coordinate(destination: .itemCreated)).eraseToAnyPublisher()

    case let .setError(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case let .linkFieldStatus(status):
        state.linkField = status

    case let .progressButton(status: status):
        state.buttonProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case let .progressView(status: status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)
    }

    return Just(.state(state)).eraseToAnyPublisher()
}
