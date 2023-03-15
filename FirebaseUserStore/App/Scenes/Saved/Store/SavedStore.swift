import Combine
import Foundation

typealias SavedStore = StateStore<SavedState, SavedAction, SavedMutation, SavedPackages, SavedLink>

extension SavedStore {
    func updatedSessionStatus(_ state: SessionState) {
        switch state {
        case .loggedIn:
            self.reinit()
            self.dispatch(.updateSaved)

        case .loggedOut:
            self.reinit()

        case .loading:
            break
        }
    }

    
}
