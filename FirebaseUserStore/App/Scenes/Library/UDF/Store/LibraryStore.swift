import Foundation
import Combine
import SwiftUDF

class LibraryStore: StateStore<LibraryState, LibraryAction, LibraryMutation, LibraryPackages, LibraryLink> { }

extension LibraryStore {
    func updatedSessionStatus(_ state: SessionState) {
        switch state {
        case .loggedIn:
            self.reinit()
            self.dispatch(.updateLibrary)

        case .loggedOut:
            self.reinit()

        case .loading:
            break
        }
        self.objectWillChange.send()
    }
}
