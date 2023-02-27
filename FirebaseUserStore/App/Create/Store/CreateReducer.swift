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

    case .progressButtonStatus(status: let status):
        break

    case .progressViewStatus(status: let status):
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
}
