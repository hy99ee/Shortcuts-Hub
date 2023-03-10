import Combine
import SwiftUI

let createReducer: ReducerType<CreateState, CreateMutation, CloseTransition> = { _state, mutation in
    var state = _state

    switch mutation {
        
    case .itemUpdate:
        break

    case .itemUploaded:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()

    case let .setError(error):
        state.error = error

    case let .progressButton(status: status):
        state.buttonProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case let .progressView(status: status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)
    }

    return Just(.state(state)).eraseToAnyPublisher()
}
