import Foundation
import Combine

enum DetailItemMutation: Mutation {
    case itemsSavedStatusChanged(with: DetailItemStore.Operation)

    case error(with: DetailItemStore.Operation, error: Error)

    case progressViewStatus(status: ProgressViewStatus)

    case `break`
}

